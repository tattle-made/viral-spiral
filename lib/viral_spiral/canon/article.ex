defmodule ViralSpiral.Canon.Article do
  alias ViralSpiral.Canon.Article

  defstruct id: nil,
            card_id: "",
            headline: "",
            type: nil,
            content: "",
            author: "",
            veracity: nil

  # @type article_type :: :blog | :news | :official
  @type t :: %__MODULE__{
          id: UXID.uxid_string(),
          card_id: String.t(),
          headline: String.t() | any(),
          type: String.t() | any(),
          content: String.t() | any(),
          author: String.t() | any(),
          veracity: boolean()
        }

  # @article_types [:blog, :news, :official]

  @spec new(String.t()) :: Article.t()
  def new(headline) do
    uxid = Application.get_env(:viral_spiral, :uxid)

    %Article{
      id: uxid.generate!(prefix: "article", size: :small),
      card_id: "card_" <> Integer.to_string(:erlang.phash2(headline))
    }
  end

  @spec set_headline(Article.t(), String.t() | any()) :: Article.t()
  def set_headline(%Article{} = article, headline) do
    %{article | headline: headline}
  end

  @spec set_type(Article.t(), String.t() | any()) :: Article.t()
  def set_type(%Article{} = article, type) do
    %{article | type: type}
  end

  @spec set_content(Article.t(), String.t() | any()) :: Article.t()
  def set_content(%Article{} = article, content) do
    %{article | content: content}
  end

  @spec set_author(Article.t(), String.t() | any()) :: Article.t()
  def set_author(%Article{} = article, author) do
    %{article | author: author}
  end

  @spec set_veracity(Article.t(), boolean()) :: Article.t()
  def set_veracity(%Article{} = article, veracity) do
    %{article | veracity: veracity}
  end
end
