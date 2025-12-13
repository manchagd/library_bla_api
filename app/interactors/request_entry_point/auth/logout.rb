# frozen_string_literal: true

module RequestEntryPoint
  module Auth
    class Logout
      include Interactor

      def call
        return context.fail!(message: 'User not provided') unless context.user

        # Revoke the token by changing the JTI
        # This invalidates all previous tokens for this user
        context.user.update!(jti: SecureRandom.uuid)
      end
    end
  end
end
