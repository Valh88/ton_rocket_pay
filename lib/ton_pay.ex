defmodule TonPay do
  @token_auth_header "8c7c17576e92834fa00811ff3"
  @url "https://dev-pay.ton-rocket.com/tg-invoices/"

  def create_invoice(url \\ @url, _options \\ []) do
    header = ["Rocket-Pay-Key": @token_auth_header, "Accept": "application/json"]
    HTTPoison.post(url, decode_body(), header) #, [recv_timeout: 500])
  end

  defp decode_body() do
    body = %{
      # amount: 6.88,
      minPayment: 2.23,
      # numPayments: 1,
      currency: "TONCOIN",
      description: "best thing in the world, 1 item",
      hiddenMessage: "thank you",
      commentsEnabled: false,
      callbackUrl: nil,
      payload: "some custom payload I want to see in webhook or when I request invoice",
      expiredIn: 86400
    }
     {:ok, body} = Poison.encode(body)
     IO.inspect(body)
     body
  end
end
