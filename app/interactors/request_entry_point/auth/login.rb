# frozen_string_literal: true

module RequestEntryPoint
  module Auth
    class Login
      include Interactor

      def call
        user = User.find_by(email: context.email)

        if user&.valid_password?(context.password)
          token, = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
          context.user = user
          context.token = token
        else
          context.fail!(message: "Invalid credentials")
        end
      end
    end
  end
end
