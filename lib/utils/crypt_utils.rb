require 'digest'
require 'digest/sha2'
require 'openssl'
require 'base64'


class CryptUtils
  ENCRYPTION_ALGORITHM = "AES-256-CBC"
  
  def self.sha_hash_hex(in_str)
    hash = Digest::SHA256.digest in_str
    hash64 = [hash].pack('m')
#    hex = hash.each_byte.map { |b| b.to_s(16) }.join
    return hash64
  end
  
  
  def self.encrypt(data)
    aes = OpenSSL::Cipher::Cipher.new(CryptUtils::ENCRYPTION_ALGORITHM)
    aes.encrypt
    #aes.key = key
    key = aes.random_key
    iv = aes.random_iv
    cipher = aes.update(data)
    cipher << aes.final
    cipher64 = [cipher].pack('m')    
    key64 = [key].pack('m')    
    iv64 = [iv].pack('m')    
    return {key: key64, encrypted_data: cipher64, iv: iv64}
  end
  
  def self.decrypt(encrypted_data64, key64, iv64)
    decode_cipher = OpenSSL::Cipher::Cipher.new(ENCRYPTION_ALGORITHM)
    decode_cipher.decrypt
    decode_cipher.key = key64.unpack('m')[0]
    decode_cipher.iv = iv64.unpack('m')[0]
    #decode_cipher.iv = iv
    plain = decode_cipher.update(encrypted_data64.unpack('m')[0])
    plain << decode_cipher.final
    return plain
  end
  
  def self.decrypt_ansible_host_response(cipher_info)
    encrypted_key = cipher_info['key']
    iv = cipher_info['iv']
    cipher = cipher_info['encrypted_data']

    private_key = OpenSSL::PKey::RSA.new File.read(ENV['HOME'] + "/.ssh/id_rsa")
    encrypted_key = encrypted_key.unpack('m')[0]
    key =  private_key.private_decrypt(encrypted_key)
    hosts_data = CryptUtils.decrypt(cipher, key, iv)
    return hosts_data
  end
  
end