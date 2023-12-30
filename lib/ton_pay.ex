defmodule TonPay do
  @type token_auth_header :: binary()
  @type header :: ["Rocket-Pay-Key": token_auth_header, "Content-Type": binary()]
  @type url :: binary()

  defmacro __using__(token) do
    unless is_binary(token) do
      raise ArgumentError, message: "Need auth token"
    end
    quote do
      @token_auth_header unquote(token)
      @url "https://dev-pay.ton-rocket.com/tg-invoices"
      @header ["Rocket-Pay-Key": @token_auth_header, "Content-Type": "application/json"]

      def create_invoice(amount, currency, options \\ []) do
        case HTTPoison.post(@url, decode_body(amount, currency, options), @header, [recv_timeout: 500]) do
          {:ok, response = %HTTPoison.Response{}} -> {:ok, Poison.decode!(response.body)["data"]}
          {:error, error = %HTTPoison.Error{}} -> {:error, error}
        end
      end

      defp decode_body(amount, currency, options) do
        comment_enabled =
          case options[:comment_enabled] do
            check when is_boolean(check) -> check
            _ -> false
          end
        body = %{
          "amount" => amount,
          # "minPayment" => 2.23,
          # numPayments: 6,
          "currency" => currency,
          "description" => options[:description] || "best thing in the world, 1 item",
          "hiddenMessage" => "thank you",
          "commentsEnabled" => comment_enabled,
          "callbackUrl" => nil,
          "payload" => options[:payload] || "some custom payload I want to see in webhook or when I request invoice",
          "expiredIn" => 86400,
        }
        {:ok, body} = Poison.encode(body)
        body
      end

      def get_list(limit \\ 100, offset \\ 0) when is_integer(limit) and is_integer(offset) do
        case HTTPoison.get(@url <> "?limit=#{limit}&offset=#{offset}", @header) do
          {:ok, response = %HTTPoison.Response{}} -> {:ok, Poison.decode!(response.body)["data"]}
          {:error, error = %HTTPoison.Error{}} -> {:error, error}
        end
      end

      def get_by_id(id_invoice) when is_binary(id_invoice) or is_integer(id_invoice) do
        case HTTPoison.get(@url <> "/#{id_invoice}", @header) do
          {:ok, response = %HTTPoison.Response{}} -> {:ok, Poison.decode!(response.body)["data"]}
          {:error, error = %HTTPoison.Error{}} -> {:error, error}
        end
      end

      def delete(id_invoice) when is_binary(id_invoice) or is_integer(id_invoice) do
        case HTTPoison.delete(@url <> "/#{id_invoice}", @header) do
          {:ok, response = %HTTPoison.Response{}} -> {:ok, Poison.decode!(response.body)}
          {:error, error = %HTTPoison.Error{}} -> {:error, error}
        end
      end
    end
  end
end
