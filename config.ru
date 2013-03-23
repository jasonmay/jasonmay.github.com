require 'bundler/setup'
require 'sinatra/base'

require 'sinatra/twitter-bootstrap'

require 'haml'

require 'json'
require 'yaml'
require 'jekyll'

$:.unshift(File.join(__FILE__, '..', 'lib'))
require 'octopress/engine'

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

class SinatraEditorServer < Sinatra::Base
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

  def posts_path(post)
    opt = Jekyll.configuration({})
    File.join(opt["source"], '_posts', post.name)
  end

  def jekyll_post(name)
    jekyll_posts.find { |p| p.name == name }
  end

  def preview_root(request)
    opt = Jekyll.configuration({})

    url = request.scheme + "://"
    url << request.host

    if request.scheme == "https" && request.port != 443 ||
       request.scheme == "http" && request.port != 80
      url << ":#{request.port}"
    end

    url << opt["root"]
    url
  end

  get('/post/:name') do
    @config = Jekyll.configuration({})
    @post = jekyll_post(params[:name])
    @preview = preview_root(request)
    haml :post
  end

  post('/save/:name') do
    @post = jekyll_post(params[:name])
    @path = posts_path(@post)
    if params["content"]
      out = @post.data.to_yaml + "---\n" + params["content"]
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
    @posts = jekyll_posts
    haml :index
  end

end

run Rack::URLMap.new("/" => SinatraStaticServer.new, "/_editor" => SinatraEditorServer.new)
