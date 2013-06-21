# encoding: utf-8
require 'rubygems'
require 'mustache'
require 'fileutils'

PREFIX = 'table-guest-cards'

raw_list = File.open('list.txt', 'r:UTF-8'){ |f| f.read }

grouped_list = raw_list.split("\n\n").map{ |group| group.split("\n") }

mustache_list = grouped_list.map{|group| group.map{ |name| {value: name} }}

FileUtils.rm_f Dir["#{PREFIX}-*"]

counter = 1
mustache_list.each_slice(2) do |group|
	puts 'Generating PDF for:'
	puts group.flatten.map{|f| ' * ' + f.values.join(',')}.join("\n")

	data = {
		group1: group[0],
		group2: group[1],
		has_group2: !group[1].nil? && !group[1].empty?
	}

	template = File.read('template.html')
	output   = Mustache.render(template, data)
	filename = "#{PREFIX}-#{counter}"
 	File.open("#{filename}.html", 'w') { |f| f.write(output) }
 	
  `wkhtmltopdf -B 0 -L 0 -R 0 -T 0 --dpi 300 --orientation landscape --page-size A4 #{filename}.html #{filename}.pdf`
  
  counter += 1
end

FileUtils.rm_f Dir["#{PREFIX}-*.html"]
