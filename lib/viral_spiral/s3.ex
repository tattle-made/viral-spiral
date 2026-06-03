defmodule ViralSpiral.S3 do
  @moduledoc """
  S3 upload and URL helpers.

  In dev, uploads go to LocalStack at localhost:4566.
  In prod, uploads go to the real AWS bucket configured via S3_BUCKET env var.

  Keys should be namespaced by purpose, e.g. "cards/{card_id}/{filename}".
  """

  @doc "Upload binary content to S3 under the given key."
  @spec upload(binary(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def upload(binary, key, content_type \\ "application/octet-stream") do
    bucket()
    |> ExAws.S3.put_object(key, binary, content_type: content_type, acl: :public_read)
    |> ExAws.request()
  end

  @doc "Delete an object from S3 by key."
  @spec delete(String.t()) :: {:ok, map()} | {:error, term()}
  def delete(key) do
    bucket()
    |> ExAws.S3.delete_object(key)
    |> ExAws.request()
  end

  @doc "Return the public URL for a stored object key."
  @spec public_url(String.t()) :: String.t()
  def public_url(key) do
    base = Application.fetch_env!(:viral_spiral, :s3_base_url)
    "#{base}/#{key}"
  end

  @doc "Build a namespaced key for a card image upload."
  @spec card_image_key(String.t(), String.t()) :: String.t()
  def card_image_key(card_id, filename) do
    ext = Path.extname(filename)
    "cards/#{card_id}/image#{ext}"
  end

  defp bucket, do: Application.fetch_env!(:viral_spiral, :s3_bucket)
end
