require 'concurrent'
require 'fileutils'
require 'net/http/persistent'
require 'tempfile'
require 'thread'

module ByeFlickr
  class PhotoDownloader

    Download = Struct.new(:url, :path, :tries)

    attr_reader :errors

    def initialize(dir, workers: 2)
      @basedir = dir
      @lock = Mutex.new
      @http = Net::HTTP::Persistent.new

      @images = Concurrent::Array.new
      @errors = Concurrent::Array.new

      @tempdir = @basedir.join 'tmp'
      FileUtils.mkdir_p @tempdir
      @running = true
      @workers = 1.upto(workers).map do |i|
        Thread.new{ Worker.new(self).run }
      end
    end

    def wait
      @running = false
      @workers.each{|t|t.join}
      if @errors.any?
        (File.open(@basedir.join('errors.json'), 'wb') << @errors.to_json).close
      end
    end

    def add_image(url, path)
      @images << Download.new(url, path, 0)
    end

    def running?
      !!@running
    end

    def next
      @images.shift
    end

    def add_failure(dl)
      @errors << dl
    end

    def download(dl)
      response = @http.request dl.url
      f = Tempfile.create('bye-flickr-download', @tempdir)
      f << response.body
      f.close

      @lock.synchronize do
        i = 0
        path = dl.path
        while File.readable?(path)
          i = i+1
          path = "#{dl.path.sub(/\.jpg$/i, '')}_#{i}.jpg"
        end
        FileUtils.mv f, path
      end

    rescue
      puts "#{$!}:\n#{dl.url} => #{dl.path}"
      dl.tries += 1
      if dl.tries > 2
        puts "giving up on this one"
        add_failure dl
      else
        @images << dl
      end
    end


    class Worker
      def initialize(downloader)
        @downloader = downloader
      end

      def run
        while @downloader.running? do
          if file = @downloader.next
            @downloader.download(file)
            print '.'
          else
            sleep 1
          end
        end
      end
    end

  end
end
