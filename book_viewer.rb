require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do

  def number_paragraphs(text)
    paragraphs = []
    text.split("\n\n").each_with_index do |paragraph, index|
      paragraphs << {"paragraph" + (index + 1).to_s => paragraph}
    end
    paragraphs
  end

  def render_paragraphs_with_tags(text)
    output = ''
    number_paragraphs(text).each do |element|
      element.each do |number, text|
        output += (%Q(<p id="#{number}">) + "#{text}" + "</p>")
      end
    end
    output
  end

  def each_chapter
    @contents.each_with_index do |chapter_title, index|
      chapter_number = index + 1
      chapter_text = File.read("data/chp#{chapter_number}.txt")
      yield chapter_title, chapter_number, chapter_text
    end
  end

  def chapters_matching(query)
    results = []
  
    return results if !query || query.empty?
  
    each_chapter do |title, number, text|
      if text.include? query.to_s
        matched_paragraphs = paragraphs_matching(text, query)
        results << {chapter_title: title, chapter_number: number, paragraphs: matched_paragraphs}
      end
    end
    results
  end
  
  def paragraphs_matching(chapter_text, query)
    matched_paragraphs = []
    number_paragraphs(chapter_text).each do |element|
      element.each do |paragraph_number, paragraph_text|
         matched_paragraphs << element if paragraph_text.include? query.to_s
      end
    end
    matched_paragraphs
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Works or Arthur Conan Doyle"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover? number

  @search_term = params['search_term']
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end
