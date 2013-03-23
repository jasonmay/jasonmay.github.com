
module Octopress
  class Engine
    ACCESSORS = [:ssh_user, :ssh_port, :document_root, :rsync_delete,
                 :rsync_args, :deploy_default, :deploy_branch, :public_dir,
                 :source_dir, :blog_index_dir, :deploy_dir, :stash_dir, :posts_dir,
                 :themes_dir, :new_post_ext, :new_page_ext, :server_port]

    attr_accessor *ACCESSORS

    def initialize(args = {})
      defaults = {
        :public_dir      => "public",
        :source_dir      => "source",
        :blog_index_dir  => 'source',
        :deploy_dir      => "_deploy",
        :stash_dir       => "_stash",
        :posts_dir       => "_posts",
        :themes_dir      => ".themes",
        :new_post_ext    => "markdown",
        :new_page_ext    => "markdown",
        :server_port     => "4000",
      }

      ACCESSORS.each do |attr|
        val = args[attr] || defaults[attr]
        if val
          self.send :"#{attr}=", val
        end
      end
    end

    def generate_filename(title)
      "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
    end

    def new_post(title, filename, verbose = true)
      puts "Creating new post: #{filename}" if verbose
      open(filename, 'w') do |post|
        post.puts "---"
        post.puts "layout: post"
        post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
        post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
        post.puts "comments: true"
        post.puts "categories: "
        post.puts "---"
      end

      filename
    end
  end
end
