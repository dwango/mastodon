# frozen_string_literal: true
module AuthProvider
  def providers
    ENV['OMNIAUTH'].to_s.split(',').map do |auth|
      provider, access_token, secret_token, scope = auth.split(':')
      OpenStruct.new(provider: provider,
                     access_token: access_token,
                     secret_token: secret_token,
                     scope: scope)
    end
  end

  module_function :providers
end
