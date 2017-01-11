class MasterSplitter

  def initialize(original_text, html_ready_to_go)
    @input_text = open(original_text).read
    @output_file = open(html_ready_to_go, 'w')
    @numerator = 0 
    @output_text = ""
  end

  def create_html_file
    file_header
    text_to_paragraph
    file_footer
    @output_file.write("#{@output_text}")

    # print "Please check that all the sentences in the html file are divided correctly, and fix them if necessary. Save the file and then hit RETURN (enter).\n"
    # $stdin.gets
    # text = File.read(@output_file)
    # replace = text.gsub(/9999/, "#{@numerator}")
    # File.open(@output_file, "w") {|file| file.puts replace}
  end

  def text_to_paragraph
    output_paragraph = @input_text.split("\n\n")
    output_paragraph = @input_text.split("\r\n\r\n") if output_paragraph.size == 1
    paragraph_to_sentenes(output_paragraph)
  end

  def paragraph_to_sentenes(output_paragraph)
    output_paragraph.each do |par|
        # output_sentence = par.split(/(?<=\!\" |\?\" |\.\" |\! |\? |\. |\; )/)

      if par[-1] == "\""
        output_sentence = par.split(/(?<=\!\" |\?\" |\.\" |\! |\? |\. |\; | \- |\.\' )/)
      else
        output_sentence = par.split(/(?<=\! |\? |\. |\; )/)
      end
      @output_text << "\t<div>\n"
      sentence_to_words(output_sentence)
      @output_text << "\t</div>\n"
    end
  end

  def sentence_to_words(output_sentence)
    output_sentence.each do |sentence|
      output_word = sentence.split(" ")
      @output_text << "\t\t<span class=\"sentence\" data-id=\"9999\">\n" #I want to have some sort of a check and then renumber.
      wrap_words(output_word)
      @output_text << "\t\t</span>\n"
    end
  end

  def wrap_words(output_word)
    output_word.each do |word|
      mwe_re_merge(output_word)
      if word.end_with?("'m", "'s", "'re", "'d", "'ve")
        new_word = word.split(/(?=\')/)
        # new_word.each do |part|
        @output_text << "\t\t\t<span>#{new_word[0]}</span>"
        @output_text << "<span>#{new_word[1]}</span>\n\n"
        # end
      else
        @output_text << "\t\t\t<span>#{word}</span>\n"
      end
    end
  end

  def mwe_re_merge(output_word)
    output_word.each_with_index do |first_word, index|
      second_word = output_word[index+1]
      third_word = output_word[index+2]
      # if (first_word.downcase == "a" && (["little", "few", "while"].include? second_word)) || 
      #     ((first_word.downcase == "each") && (second_word == "other")) ||
      #      ((first_word.downcase == "as") && (second_word == "soon") && (third_word == "as"))
      case [first_word.downcase, second_word]
      when ["a", "little"], ["a", "while"], ["a", "few"], ["each", "other"]
        second_word.gsub(/[[:punct:]]/, '')
        mwe_two_words = [first_word, second_word].join(" ")
        output_word[index..index+1] = [mwe_two_words]
      end
      case [first_word.downcase, second_word, third_word]
      when ["as", "soon", "as"]
        p third_word
        third_word.gsub(/[[:punct:]]/, '')
        mwe_three_words = [first_word, second_word, third_word].join(" ")
        output_word[index..index+2] = [mwe_three_words]
      end
    end
  end

  def file_header
    print "What is the name of the story?\n"
    story_name = $stdin.gets.chomp
    print "Who is the author? If this is a folk tale, leave blank and edit later.\n"
    author_name = $stdin.gets.chomp
    print "Is the story translated? If so, from which language? If leave blank and edit later.\n"
    origin_language = $stdin.gets.chomp
    print "Translated by whom?\n"
    translator = $stdin.gets.chomp
    html_header = "<page>\n<header>\n<h1>#{story_name}</h1>\n<h2><span>by #{author_name}</span></h2>\n<h3><span>Translated from #{origin_language} by #{translator}</span></h3>\n</header>\n"    
    @output_text << html_header
  end

  def file_footer
    html_footer = %q{<div class="reading-summary-report">
        <button><span class="icon reading-report-btn-icon"></span>Practice My English</button>
        </div>
        </page>}
    @output_text << html_footer
  end

end

print "Enter story file name in the following format: story_name_author_name\n"
story_file_name = $stdin.gets.chomp
story = MasterSplitter.new("#{story_file_name}.txt", "#{story_file_name}.html")
story.create_html_file