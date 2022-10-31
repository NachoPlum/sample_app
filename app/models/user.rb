class User < ApplicationRecord
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
  validates :password, presence: true, length: { minimum: 8 }, format: PASSWORD_REQUERIMENTS
end
