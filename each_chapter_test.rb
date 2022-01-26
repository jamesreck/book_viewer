=begin
* Iterate through each chapter
  * For each chapter with a match:
    * Create a hash {chapter_title: title, chapter_number: number, paragraphs: {paragraph_number, paragraph text}}




* Iterate through results array to access each chapter hash. For each chapter hash:
  * Create a list item with the chapter name.
  * Iterate through the chapter hash to access each search result. For each search result:
    * Display a sub-list item with the text of the result as the link text. Use the chapter number and paaragraph number to
      create the anchor element link.
=end

@contents = File.readlines("data/toc.txt")
@chapter1 = File.read("data/chp1.txt")

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

def number_paragraphs(text)
  paragraphs = []
  text.split("\n\n").each_with_index do |paragraph, index|
    paragraphs << {(index + 1).to_s => paragraph}
  end
  paragraphs
end

def render_paragraphs_with_tags(text)
  output = ''
  number_paragraphs(text).each do |element|
    element.each do |number, text|
      output += (%Q(<p id="paragraph#{number}">) + "#{text}" + "</p>")
    end
  end
  output
end

chapters_matching("pistol").each do |result|
  result[:paragraphs].each do |array|
    array.each do |number, text|
      puts text
    end
  end
end



    





