class File_Parser
  def initialize(file)
    @original_file = file
    @file = File.open(file, 'r+').readlines
    @parsed_object = {}
    parser
  end
  
  def get_value (section, key, type)
    value = @parsed_object[section][key]
    if type == "integer"
     value.to_i
    elsif type == "float" 
      value.to_f 
    elsif type == "string" 
      value.to_s
    else
      "Please choose a type between: 'string', 'integer', and 'float'"
    end
  end

  def set_value (section, key, value)
    @parsed_object[section][key] = value.to_s
    update_file
  end

  private

  def parser
    @file.each_with_index do |line, index|
      line.strip!
      check_and_set_continuation(line, index)
      check_and_set_key_value(line)
      check_and_set_section(line)
    end
  end

  def check_and_set_continuation(line, index)
   if @file[index +1]
      next_line = @file[index + 1].strip
      until /^\[(.*?)\]/.match(next_line) or /:/.match(next_line) or next_line == ""
        line.concat(" " + @file.slice!(index+1).strip!)
        next_line = @file[index + 1].strip  
      end
    end
  end

  def check_and_set_key_value(line) 
    if /:/.match(line)
      key_value = line.split(":")
      key = key_value[0].strip
      value = key_value[1].strip 
      @parsed_object[@section][key] = value
    end
  end

  def check_and_set_section(line)
    if /^\[(.*?)\]/.match(line) 
      line.sub! /\[?\s*/, ''
      line.sub! /^?\s*\]/, ''
      @section = line
      @parsed_object[line] = {}
    end
  end
  
  def update_file
    File.open(@original_file, 'w') do |f|
      @parsed_object.each do |section, keys|
        f.puts ""
        f.puts "[" + section + "]"
        f.puts ""
        keys.each do |key, value|
          f.puts key + " : " + value
        end
      end
    end
  end 

end

data = File_Parser.new("test_data.txt")


# TESTS

p "1. Sets and Gets a String Value with given section and key names"
data.set_value("header","new key","new value")
p data.get_value("header","new key","string") == "new value"


p "2. Sets and Gets a Integer Value with given section and key names"
data.set_value("meta data","new key2",75)
p data.get_value("meta data","new key2","integer") == 75


p "3. Sets and Gets a Float Value with given section and key names"
data.set_value("trailer","new key3",10.1)
p data.get_value("trailer","new key3","float") == 10.1

p "4. Improper 'type' when getting value prompts options"
p data.get_value("trailer","new key3","boat") == "Please choose a type between: 'string', 'integer', and 'float'"
