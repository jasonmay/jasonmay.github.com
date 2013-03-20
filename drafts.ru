require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/twitter-bootstrap'

require 'haml'

require 'json'
require 'yaml'
require 'jekyll'

# The project root directory
$root = ::File.dirname(__FILE__)

class SinatraDraftsServer < Sinatra::Base
  set :views => "drafts/views"

  register Sinatra::Twitter::Bootstrap::Assets

  get(%r[^/static/.+]) do
    path = 'drafts' + request.path # drafts/static/...
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
    @drafts = jekyll_posts
    haml :index
  end

end

run SinatraDraftsServer
