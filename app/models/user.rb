class User < ApplicationRecord
  validates :email, uniqueness: true

  def self.create_user(options)
    User.create(options.except("id", "event_type"))
  end

  def self.destroy_user(options)
    record = User.find_by(email: options["email"])
    return if record.blank?

    record.destroy!
  end

  def self.update_user(options)
    record = User.find_by(email: options["email"])
    return if record.blank?

    record.update(options.except("id", "event_type"))
  end
end
