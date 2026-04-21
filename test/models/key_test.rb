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
    assert_equal "-----BEGIN RSA PRIVATE KEY-----\nMIIBOgIBAAJBANZvy4RPYzHo8AanOJjpNlg74fI7XzRoL+GMOm0bOAktyc7Q+L7h\nGldAlQj1gXmHUI8AmuidxMOmb+YYL6ZYSDkCAwEAAQJAP894smClVf7JHlG4h9gu\nMcdwDxMX25J9XRLLeBg3bpNDnineWEDFlyTE8omfFZYER/KphfK4Sg2phfY13Qrm\n2QIhAP8NlnS5LH/scY7D9ubfIWY6wiaKQFQXlNiJgyeT/JAnAiEA1zuamP9WYXKg\nqMNLMOPJ/wsxmOEoZ41MzIfF5FmnQJ8CIQDzbK99hcJf8XXMUWITpUBGRqxIhkix\nObR5Gn2Px6EUnwIgBxSi5V2hDdujhWnHU3hq8MUBgLIHjkCLwj7FN9nrMqkCIFDa\nik9XYqJoVlJyWKweAT5tj+mkOLyA1Vu5YFGDlxT7\n-----END RSA PRIVATE KEY-----\n", keys(:root).pem
    assert_equal "-----BEGIN RSA PRIVATE KEY-----\nMIIBOgIBAAJBAM1uzMTsQI2lOu/XiivpqjGjUNT7zx1CJBtrZRM2+IDvcqCY3Z0u\n9w1tyMcpAi3NErHWhiY2QR4yWhNFcKk2OkMCAwEAAQJAVS08n+Wo+lHo9urycjSn\nCX/Ckxx5CpOS7v9/YBEpxiNDjnXU0kuTHZ4fSQM5l9sBpE1LS9giEzI4xXeMWWNy\neQIhAPBBPXvQd64MfiAqhRGvV3Xoq82Due+QkDXDUXVRfNfnAiEA2uVZj6RCCRbI\nEAa1OxvEgAxqWIdSC/mnMR5ZDaOaj0UCIDm2gk1+y3EM4TNa43JXG3xgcvzAWub4\nZBv2GlhDRekbAiAex0brkp4SZxikYD0VXZcophZB8m0P7/+ZQXomF84AvQIhAJTz\nP7jAayovB1fWGj7e6k6bA1uWHq6cKXwWZvshN9f2\n-----END RSA PRIVATE KEY-----\n", keys(:intermediate).pem
    assert_equal "-----BEGIN RSA PRIVATE KEY-----\nMIIBOQIBAAJBALUPQ/QYTqiwUcQFTp1eMJx2PWOFk3rVP+spizF3UteGCggVqqEV\nbcmbFCvq/1YkV9StMufsY39XDHpsdGHlPAUCAwEAAQJAONWd4xVuO419XSa9UrCq\nWbLT+lWHwdsGwW68/r4SBwzJD8lawAMGqvuNwrB2QGnWNz6Hf0iTIXaBEhFWJUVE\n0QIhANvu/8r2IcPZDA8Ll9qQofy2LbZ4FNGDNMsOJrLvxQszAiEA0sBN1zBUmEs5\nPv0BcujZbpF44ajVzEwnZplKSFtvW+cCIFpMusF+ZUagKw9SVzrp/1hfBE3S59lN\n4bMtUD5Pq7t5AiBp09ECpq1EEDn9zDRHDG/qmrf1sL8zKGZ8mar4bJmdrwIgFiHn\nmW4dyafXxr1p22V1UlNuU1RjYVJQy+BH3RYfUuw=\n-----END RSA PRIVATE KEY-----\n", keys(:server).pem
  end
end
