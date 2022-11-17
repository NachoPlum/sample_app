class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  #Validacion name, presencia, largo
  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  #Validacion email, presencia, largo, formato y unicidad
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX}, uniqueness: true
  # Agregando password
  has_secure_password

  PASSWORD_REQUERIMENTS = /\A (?=.{8,}) (?=.*\d)(?=.*[a-z]) (?=.*[A-Z]) (?=.*[[:^alnum:]])/x
  # Validando, Min 8 char, Min 1 numero Min 1 Minuscula, Min 1 Mayuscula y Min 1 Simbolo
  #validates :password, format: PASSWORD_REQUERIMENTS
  validates :password, presence: true, length: { minimum: 8 },allow_nil: true, format: PASSWORD_REQUERIMENTS

    # Returns the hash digest of the given string.
    def self.digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    #Devuelve un token random de 22 caracteres
    def self.new_token
      SecureRandom.urlsafe_base64
    end

    # Guarda al usuario en la base de datos para usarlo en sesiones persistentes
    def remember
      self.remember_token = User.new_token
      update_attribute(:remember_digest, User.digest(remember_token))
      remember_digest
    end

    # Returns a session token to prevent session hijacking.
    # We reuse the remember digest for convenience.
    def session_token
      remember_digest || remember
    end
    #Devuelve True si el token es igual al digest
    def authenticated?(remember_token)
      return false if remember_digest.nil?
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
    # Forgets a user.
    def forget
     update_attribute(:remember_digest, nil)
    end
end
