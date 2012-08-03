require 'nokogiri'
require 'pathname'
require 'net/http'
require 'uri'
require_relative 'core_ext'

# Some helpers

def get(url)
  uri = URI.parse(url)
  Net::HTTP.get_response(uri).body
end

def fail(oh_dear)
  abort "Error: #{oh_dear}\n".red
end

puts "
===================
Welcome to xkcdown!
===================

"

print "Getting the ID of the latest comic: "

doc = Nokogiri::HTML(get("http://xkcd.com/archive/"))
newest = doc.css('#middleContainer a').first.attributes["href"].value.gsub('/','').to_i

puts "#{newest}.

"

# defaults
dir = "images"
range = 1..newest # all comics
id = false
title = false

# parse arguments
# integer arguments assume from x to latest comic
# arguments in form x-y are taken as a range
# arguments in form -t, -it are taken as options
# anything else is a dir name to store comics in

ARGV.each do |a|
  case a
  when /\A-([a-z]+)\Z/i # -options
    opts = $1
    opts.each_char do |c|
      case c
      when 'i'
        id = true
      when 't'
        title = true
      end
    end
  when /\A[0-9]+\Z/ # single comic
    range = a.to_i..a.to_i
  when /\A[0-9]+-[0-9]+\Z/ # range of comics
    parts = a.split('-').map(&:to_i)
    fail "Bad range #{a}." if parts[0] >= parts[1]
    range = Range.new(*parts)
  else
    dir = a
  end
end

# defualt naming files by id to true
# unless they choose to name files by titles
id = true unless title

# validate all ranges
fail "Range exceeds ID of latest comic." if range.last > newest
fail "Range must start at 1 or more." if range.first < 1

if File.exists? dir
  abort "File #{a} exists, but is not a directory." unless File.directory? dir
else
  Dir.mkdir(dir)
end

dir_path = Pathname.pwd + dir

print "Downloading comics: "

range.each do |n|
  next if n == 404 # not a comic (page not found)

  # log progress
  print n == range.last ? n : "#{n},"
 
  # download comic page and get image url
  url = "http://xkcd.com/#{n}/"
  doc = Nokogiri::HTML(get(url))
  img = doc.css('#comic img').first
  if img.nil?
    puts "\nError downloading #{n} - img tag not found, skipping...\n\n"
    next
  end
  img_url = img.attributes["src"].value

  # download and save image
  uri = URI.parse(img_url)
  Net::HTTP.start(uri.host) do |http|
    resp = http.get(uri.path)
    remote_fn = uri.path.split('/').last
    parts = remote_fn.split('.')
    ext = parts.last
    fn_noext = parts.clip.join

    filename = ""
    if id
      filename << "#{n}"
      filename << " " if title
    end
    filename << "#{fn_noext}" if title
    filename << ".#{ext}"

    open(dir_path + filename, "wb") do |file|
      file.write(resp.body)
    end
  end
end

puts "
All comics downloaded!
"


puts "
========================================
Thanks for using xkcdown, by @alexcoplan
========================================

"