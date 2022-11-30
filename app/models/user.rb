class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
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
    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end
    # Forgets a user.
    def forget
     update_attribute(:remember_digest, nil)
    end

    # Activates an account.
    def activate
      update_columns(activated: true, activated_at: Time.zone.now)
    end
    # Sends activation email.
    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end

    # Sets the password reset attributes
    def create_reset_digest
      self.reset_token = User.new_token
      update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    # Send password reset email
    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end

    # Returns true if a password reset has expired.
    def password_reset_expired?
      reset_sent_at < 2.hours.ago
    end

    private

      # Convertes email to all lowercase
      def downcase_email
        self.email.downcase!
      end

      #Creates and assigns the activation token and digest.
      def create_activation_digest
          self.activation_token = User.new_token
          self.activation_digest = User.digest(activation_token)
      end
end
