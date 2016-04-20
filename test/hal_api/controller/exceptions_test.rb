require 'test_helper'

describe HalApi::Errors do
  describe HalApi::Errors::UnsupportedMediaType do
    let(:subject) { HalApi::Errors::UnsupportedMediaType.new('foo') }

    it 'has status 415' do
      subject.status.must_equal 415
    end

    it 'has a helpful message' do
      subject.message.must_be :kind_of?, String
    end
  end

  describe HalApi::Errors::NotFound do
    let(:subject) { HalApi::Errors::NotFound.new }

    it 'has status 404' do
      subject.status.must_equal 404
    end

    it 'has a helpful message' do
      subject.message.must_be :kind_of?, String
    end
  end
end
