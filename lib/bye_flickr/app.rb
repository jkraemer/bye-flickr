require 'fileutils'
require 'json'
require 'pathname'
require 'bye_flickr/auth'
require 'bye_flickr/photo_downloader'
require 'bye_flickr/response_to_json'

module ByeFlickr
  class App
    def initialize(dir: '.')
      @basedir = Pathname(dir)
      FileUtils.mkdir_p @basedir

      @downloader = ByeFlickr::PhotoDownloader.new(@basedir)
    end

    # This code does not take into account pagination. 500 photos per set (the
    # maximum supported per_page value) is enough for my purposes.
    def run
      user = Auth.call
      @username = user[:username]
      @id = user[:id]
      exit if @username.nil? || @id.nil?

      # Download photos that are not in any set
      download_not_in_set

      # Get collection info
      @collections = flickr.collections.getTree
      write_info(
        @collections, path('collections.json')
      )

      # Get sets info
      @sets = Hash[
        flickr.photosets.getList(per_page: 500).photoset.map{|s|[s.id, s]}
      ]

      # Download collections and their included sets, removing downloaded sets
      # from the @sets list
      @collections.collection.each do |collection|
        download_collection collection
      end

      # download the remaining sets, which aren't in any collection
      @sets.values.each do |set|
        download_set set, @basedir
      end

      # Fetch contacts and groups meta data
      write_info(
        flickr.contacts.getList, path('contacts.json')
      )
      write_info(
        flickr.people.getGroups(user_id: @id), path('groups.json')
      )

      # wait for photo downloads to finish
      @downloader.wait
    end

    def path(name, base = @basedir)
      base.join(name.gsub(%r{/}, '_'))
    end

    def subdir(name, base = @basedir)
      path(name, base).tap do |dir|
        FileUtils.mkdir_p dir
      end
    end

    def download_not_in_set
      dir = subdir 'not in any set'
      download_photos_to_dir(
        flickr.photos.getNotInSet(extras: 'url_o', per_page: 500),
        dir
      )
    end

    # can collections be nested? If so, this code ignores them.
    def download_collection(collection)
      dir = subdir collection.title
      FileUtils.mkdir_p dir
      write_info collection, path("#{collection.title}.json")
      collection.set.each do |set|
        download_set set, dir
        @sets.delete set.id # remove this set from the lists of sets to download
      end
    end

    def download_set(set, basedir)
      dir = subdir set.title, basedir

      download_photos_to_dir(
        flickr.photosets.getPhotos(photoset_id: set.id,
                                   per_page: 500,
                                   user_id: @id,
                                   extras: 'url_o').photo,
        dir
      )

      write_info(
        flickr.photosets.getInfo(photoset_id: set.id),
        path("#{set.title}.json", basedir)
      )
    rescue Net::OpenTimeout
      puts "#{$!} - retrying to download Set #{set.title}"
      retry
    end

    def write_info(info, path)
      (File.open(path, 'wb') << ResponseToJson.(info)).close
    end

    def download_photos_to_dir(photos, dir)
      puts dir
      photos.each do |photo|
        name = photo.title
        name = name + '.jpg' unless name =~ /\.jpg$/i
        name = "#{photo.id}.jpg"
        @downloader.add_image photo.url_o, path(name, dir).to_s
      end

      photos.each do |photo|
        write_info(
          flickr.photos.getInfo(photo_id: photo.id),
          path("#{photo.id}.json", dir)
        )
      end
    end

  end
end
