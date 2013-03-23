require 'bundler/setup'
require 'sinatra/base'

require 'sinatra/twitter-bootstrap'

require 'haml'

require 'json'
require 'yaml'
require 'jekyll'
# The project root directory
$root = ::File.dirname(__FILE__)

class SinatraStaticServer < Sinatra::Base

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_sinatra_file('404.html') {"Sorry, I cannot find #{request.path}"}
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end

class SinatraDraftsServer < Sinatra::Base
  set :views => "editor/views"

  register Sinatra::Twitter::Bootstrap::Assets

  get(%r[^/static/(.+)]) do
    path = "editor/static/#{params[:captures].first}"
    if File.exists?(path)
      send_file(path)
    else
      raise Sinatra::NotFound
    end
  end

  not_found do
    "Page not found"
  end

  def jekyll_site
    opt = Jekyll.configuration({})
    Jekyll::Site.new(opt)
  end

  def jekyll_posts
    site = jekyll_site
    site.reset
    site.read
    site.posts
  end

  def drafts_path(draft)
    opt = Jekyll.configuration({})
    File.join(opt["source"], '_posts', draft.name)
  end

  def jekyll_post(name)
    jekyll_posts.find { |p| p.name == name }
  end

  get('/draft/:name') do
    @config = Jekyll.configuration({})
    @draft = jekyll_post(params[:name])
    haml :draft
  end

  post('/save/:name') do
    @draft = jekyll_post(params[:name])
    @path = drafts_path(@draft)
    if params["content"]
      out = @draft.data.to_yaml + "---\n" + params["content"]
      f = File.open(@path, "w")
      f.write(out)
      f.close
      jekyll_site.process
      return "OK"
    else
      return [500, {"content_type" => "text/plain"}, ["No content"]]
    end
  end

  get('/') do
    @config = Jekyll.configuration({})
    @drafts = jekyll_posts
    haml :index
  end

end

run Rack::URLMap.new("/" => SinatraStaticServer.new, "/_editor" => SinatraDraftsServer.new)
