require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe 'default settings' do
    it 'uses the correct default from email address' do
      expect(ApplicationMailer.default[:from]).to eq('no-reply@shardsofthegrid.com')
    end


  end
end