require "test_helper"

class KeyTest < ActiveSupport::TestCase
  test "methods" do
    key = Key.new
    assert key.respond_to? :user
    assert key.respond_to? :certificates
  end

  test "create" do
    user = users(:one)
    key = Key.create(user: user)

    assert_equal user.id, key.user.id
    assert_not_nil key.content
  end

  test "pem" do
    assert_equal "-----BEGIN RSA PRIVATE KEY-----\nMIIBPAIBAAJBAPtDB6Egn7XZkmKWmXvHaQdGaU+Wr1Zt8A1i6W/X74i+pOQ5XW16\nQPGzpTquu/zxv3+xjbQ3CYp6JpL5dSmCIBECAwEAAQJBAM4FmzbiEjLA8MfH5pfY\n3WSqtmUdEC4VPPUs+m3LqEv9LjnwiO1g3Tb0eNiJ4C8j/87n97ze30o5Z4ph94+b\njfECIQD+aNcqyoWFpD6kZPz9/jbfiAB97pJWD+s/fSAyXFONxQIhAPzVJtW+rakL\nEXdlGsdmI9gFkLiMvqPWmCLlzUjfbpndAiEAkf7GI3dPAm9Lx3lwua1t/f8FET+c\nWKkP/kIm/N+Az2UCIFwfMho5cr8gKEoPjbVPswm35WZI6gF6ZE562tSNjJgFAiEA\n9QY1wwSsAeaMEemFCSqYjcpifUxxBCP88L+AEsVCKdE=\n-----END RSA PRIVATE KEY-----\n", keys(:root).pem
    assert_equal "-----BEGIN RSA PRIVATE KEY-----\nMIIBOwIBAAJBAL4S9fdfHKv5+GmzLFgc84gL1CWxl1M68+UTZqd6o2eI/HRagNjK\nSwuatig6MY5D5kDmSzNmtF97ZRuFp+97ULcCAwEAAQJADfttFp5riIch6/yfNXgj\nvg1ItOEkhZ3flSlhMs7FuHbtmELlkKubsw0+L66bswH1y8KLBAnMM2/8e8Ekr7PT\noQIhAPdsQBYUNBX15eL/kaRJO3UqqMwP5Z1Sc+HOIRYUWXsxAiEAxKnFCjM9dLfG\nEe2e+TD6l8JgLvp3kn+O7Li61eL2wGcCIQCiVbTqh5DxA6g0OohdKOtI4ZdkY928\nTdfYRH0y1mErUQIgecmMrTFoKIS6E1Ys8bKkLSEBQXZ4X+/AidYoVdY06pcCIQCA\nWFHuithNSMb4hqsB/WfbOsZXT8oySanQqJOrlB2Fxg==\n-----END RSA PRIVATE KEY-----\n", keys(:intermediate).pem
    assert_equal "-----BEGIN RSA PRIVATE KEY-----\nMIIBPAIBAAJBAM3ezgcKewUxXA4waDYEXaYy3/c1GuZaD/7ZBpuEOItHd8bJLJxB\n/agKzOYSqG66XQpNUZFxcV4zf99tCQgrmKcCAwEAAQJAekFxKl8/9TJ9z3NRv5pS\nHuuhc0XXJqqfSyGIufwINDT4cj7r6BQMqlBBCn4QXj4+IRYvkXV3JPb4gTz199lH\nUQIhAPdJuDUfDShc1Q21UtRQgLWwmoAB+Xhrm3fXW7FRPJ0pAiEA1R+KjJSoCa7s\nPO0R7TQhuKrfZEythJ+lwz1pDJdYcU8CIQCleehRa9DzNIPBY5fkyWYHrwEELc4R\nnfhwDmWmV1U3WQIhAI4IQzGFMKejZ9UCuVu3znFfjxks8MbeDn6bQpMdmdeJAiEA\n16M6w2IWIDhHkHmBszu/9cWqUN7jVegfZ3AicrUEyFk=\n-----END RSA PRIVATE KEY-----\n", keys(:server).pem
  end
end
