#allow rotation to be a value or an array of values
class Encryptor
  attr_reader :rotation

  def initialize(options = { rotation: 13 })
    @rotation = options[:rotation]
  end

  def encrypt_file(file, options = {rotation: @rotation})
    parse_file_for('encryption', file, options[:rotation])
  end

  def decrypt_file(file, options = {rotation: @rotation})
    parse_file_for('decryption', file, options[:rotation])
  end

  def encrypt(string, rotation)
    encryption_rotation = rotation || @rotation
    encrypted_string = set_cryptography(string, encryption_rotation)
  end

  def decrypt(string, rotation)
    decrypt_rotation = rotation || @rotation - (@rotation*2)
    decrypted_string = set_cryptography(string, {rotation: decrypt_rotation})
  end

  def crack(string)
    supported_characters.size.times do |index|
      puts "rotation value: #{index},  message: #{decrypt(string, index)}"
    end
  end

  private

  def supported_characters
    (" ".."z").to_a
  end

  def message_cipher(options = {rotation: @rotation})
    rotated_characters = supported_characters.rotate(options[:rotation])
    pairs              = supported_characters.zip(rotated_characters)
    Hash[pairs]
  end

  def parse_file_for(method, file, rotation)
    encryption_method = (method == 'encryption') ? 'encrypted' : 'decrypted'
    input_file        = File.open(file, "r")
    input_file_text   = input_file.read
    parsed_file_text  = encrypt_or_decrypt(method, input_file_text, rotation)
    parsed_input_file = File.open("#{file.gsub('.encrypted','')}.#{encryption_method}", "w")
    parsed_input_file.write(parsed_file_text)
    parsed_input_file.close
    puts "file #{encryption_method} successfully"
  end

  def encrypt_or_decrypt(method, input_text, rotation)
    case method
      when "encryption" then encrypt(input_text, rotation)
      when "decryption" then decrypt(input_text, rotation)
      else raise "not able to encrypt or decrypt file based on '#{method}' method name"
    end
  end

  def set_cryptography(string, options = {rotation: @rotation})
    letters = string.split("")
    map_letters = map_letters(letters, options[:rotation])
    map_letters.join
  end

  def map_letters(letters, rotation)
    letters.map do |letter|
      cypher = message_cipher(rotation: rotation)
      cypher[letter]
    end
  end
end