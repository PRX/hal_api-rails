require 'test_helper'

describe HalApi::Errors do

  describe HalApi::Errors::ApiError do
    let(:subject) { HalApi::Errors::ApiError.new('foo', nil, 'bar') }

    it 'has status 500' do
      subject.status.must_equal 500
    end

    it 'has a helpful message' do
      subject.message.must_equal 'foo'
    end

    it 'has a helpful hint' do
      subject.hint.must_equal 'bar'
    end
  end

  describe HalApi::Errors::NotFound do
    let(:subject) { HalApi::Errors::NotFound.new }

    it 'has status 404' do
      subject.status.must_equal 404
    end

    it 'has a helpful message' do
      subject.message.must_be :kind_of?, String
      subject.message.must_equal "Resource Not Found"
    end
  end

  describe HalApi::Errors::UnsupportedMediaType do
    let(:subject) { HalApi::Errors::UnsupportedMediaType.new('foo') }

    it 'has status 415' do
      subject.status.must_equal 415
    end

    it 'has a helpful message' do
      subject.message.must_be :kind_of?, String
    end
  end
end
