
class Octopress
  attr_accessor :ssh_user, :ssh_port, :document_root, :rsync_delete,
                :rsync_args, :deploy_default, :deploy_branch, :public_dir,
                :source_dir, :blog_index_dir, :deploy_dir, :stash_dir, :posts_dir,
                :themes_dir, :new_post_ext, :new_page_ext, :server_port

  def initialize(attrs = {})
    attrs.each do |k, v|
      self.send :"#{k}=", v
    end
  end

  def new_post(title)
    raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
    FileUtils.mkdir_p "#{source_dir}/#{posts_dir}"
    filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
    if File.exist?(filename)
      abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
    end
    puts "Creating new post: #{filename}"
    open(filename, 'w') do |post|
      post.puts "---"
      post.puts "layout: post"
      post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
      post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
      post.puts "comments: true"
      post.puts "categories: "
      post.puts "---"
    end
  end
end
