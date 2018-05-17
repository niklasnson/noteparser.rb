class NoteParser
  VERSION = '1.2.1'

  def initialize(filename)
    @buffert = Buffert.new(filename)
    @buffert.bufref_K = Meta.collect_key_words(@buffert)
  end

  def run
    Process.downcase(@buffert)
    Process.markup(@buffert)
  end

  def render_buffert
    puts
    puts "~" * 75
    Meta.title(@buffert)
    puts "~" * 75
    puts Process.strip_trailing_spaces(Meta.body(@buffert))
    puts "~" * 75
    puts
  end

  class Buffert

    attr_accessor :bufref_T
    attr_accessor :bufref_K

    def initialize(filename)
      @bufref_T = open_buffer(filename)
      @bufref_K = []
    end

    def open_buffer(filename)
      a = Array.new
      File.open(filename).each_line do |line|
        line.strip!
        if line.empty?
          line += "\n"  # preserve new lines in the buffert
        end
        a.concat(line.split(/ /))
      end
      a
    end

  end #Content

  class Process

    def self.downcase(buffert)
      buffert.bufref_T.map! do |ref|
        if ref.start_with?("=")
          ref
        else
          ref.downcase
        end
      end
    end

    def self.markup(buffert)
      # images =filename=
      buffert.bufref_T.map.with_index do |w, i|
        if w.match(/=(.+)=/)
          src = w.delete '='
          buffert.bufref_T[i] = '<center><img src="' + src + '"></center>'
        end
      end
    end

    def self.elitify(string)
      string.gsub!('e', '€')
      string.gsub!('s', '$')
      string.gsub!('o', '0')
      string.gsub!('w', '''//')
      return string
    end

    def self.to_blocks(buffert)
      start_tag = "<p>"
      end_tag   = "</p>"

      output =+ start_tag
      buffert.bufref_T.map.with_index do |w, i|
        if w.eql?("\n")
          output.strip!
          output += end_tag + start_tag
        else
          output += w + " "
        end
      end
      output + end_tag
    end

    def self.strip_trailing_spaces(string)
      string.gsub!(' <', '<')
      string
    end

    def self.strip_date_stamp(string)
      string.gsub!(/^{\s\d{4}-\d{2}-\d{2}@\d{2}:\d{2} }/, '')
    end

  end #Process

  class Meta

    def self.reading_time(buffert)
      words_per_minute = 236

      total_reading_time = (buffert.bufref_T.size / (words_per_minute/60)).floor
      total_reading_time
      if total_reading_time < 60
        return "{ > 1 min }"
      else
        return "{ #{total_reading_time/60} min }"
      end
    end

    def self.title(buffert)
      puts "title: \t #{Process.elitify(buffert.bufref_K.join(", "))} #{Meta.reading_time(buffert)}"
    end

    def self.body(buffert)
      Process.to_blocks(buffert)
    end

    def self.collect_key_words(buffert)
      keywords = []
      buffert.bufref_T.map.with_index do |w, i|
        if w.match(/_(\S+)_/)
          key = w.delete '_'
          buffert.bufref_T[i] = key
          keywords << key
        end
      end
      keywords
    end
  end #Meta

end #Mania


# open a textfile
