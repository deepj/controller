require 'test_helper'

Lotus::Action::CookieJar.class_eval do
  def include?(hash)
    key, value = *hash
    @cookies[key] == value
  end
end

describe Lotus::Action do
  describe 'cookies' do
    it 'gets cookies' do
      action   = GetCookiesAction.new
      _, headers, body = action.call({'HTTP_COOKIE' => 'foo=bar'})

      action.send(:cookies).must_include({foo: 'bar'})
      headers.must_equal({'Content-Type' => 'application/octet-stream; charset=utf-8', 'Set-Cookie' => 'foo=bar'})
      body.must_equal ['bar']
    end

    it 'sets cookies' do
      action   = SetCookiesAction.new
      _, headers, body = action.call({})

      body.must_equal(['yo'])
      headers.must_equal({'Content-Type' => 'application/octet-stream; charset=utf-8', 'Set-Cookie' => 'foo=yum%21'})
    end

    it 'sets cookies with options' do
      tomorrow = Time.now + 60 * 60 * 24
      action   = SetCookiesWithOptionsAction.new
      _, headers, body = action.call({expires: tomorrow})

      headers.must_equal({'Content-Type' => 'application/octet-stream; charset=utf-8', 'Set-Cookie' => "kukki=yum%21; domain=lotusrb.org; path=/controller; expires=#{ tomorrow.gmtime.rfc2822 }; secure; HttpOnly"})
    end

    it 'removes cookies' do
      action   = RemoveCookiesAction.new
      _, headers, body = action.call({'HTTP_COOKIE' => 'foo=bar;rm=me'})

      headers.must_equal({'Content-Type' => 'application/octet-stream; charset=utf-8', 'Set-Cookie' => "foo=bar\nrm=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"})
    end

    describe 'with default cookies' do
      it 'gets default cookies' do
        action   = GetDefaultCookiesAction.new
        action.class.configuration.cookies({
          domain: 'lotusrb.org', path: '/controller', secure: true, httponly: true
        })

        _, headers, _ = action.call({})
        headers.must_equal({'Content-Type' => 'application/octet-stream; charset=utf-8', 'Set-Cookie' => 'bar=foo; domain=lotusrb.org; path=/controller; secure; HttpOnly'})
      end

      it "overwritten cookies' values are respected" do
        action   = GetOverwrittenCookiesAction.new
        action.class.configuration.cookies({
          domain: 'lotusrb.org', path: '/controller', secure: true, httponly: true
        })

        _, headers, _ = action.call({})
        headers.must_equal({'Content-Type' => 'application/octet-stream; charset=utf-8', 'Set-Cookie' => 'bar=foo; domain=lotusrb.com; path=/action'})
      end
    end
  end
end
