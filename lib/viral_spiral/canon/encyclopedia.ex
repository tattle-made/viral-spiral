defmodule ViralSpiral.Canon.Encyclopedia do
  @moduledoc """
  Load encyclopedia data from .csv file
  """
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Article

  @filenames [
    "encyclopedia_anti_blue.csv",
    "encyclopedia_anti_red.csv",
    "encyclopedia_anti_yellow.csv",
    "encyclopedia_cat.csv",
    "encyclopedia_conflated.csv",
    "encyclopedia_highfive.csv",
    "encyclopedia_houseboat.csv",
    "encyclopedia_skub.csv",
    "encyclopedia_socks.csv",
    "encyclopedia_topical.csv"
  ]

  def load_articles() do
    @filenames
    |> Enum.map(fn filename ->
      File.stream!(Path.join([File.cwd!(), "priv", "canon", filename]))
      |> CSV.decode()
      |> Enum.drop(1)
      |> Enum.drop(1)
      |> Enum.map(&parse_row/1)
      |> Enum.flat_map(& &1)
    end)
    |> Enum.flat_map(& &1)
  end

  defp parse_row(row) do
    case row do
      {:ok, row} -> format_row(row)
      {:error, _} -> {:error, "Unable to parse row"}
    end
  end

  defp format_row(row) do
    [
      Article.new(Enum.at(row, 0))
      |> Article.set_headline(Enum.at(row, 0))
      |> Article.set_type(Enum.at(row, 1))
      |> Article.set_content(Enum.at(row, 2))
      |> Article.set_author(Enum.at(row, 3))
      |> Article.set_veracity(true),
      Article.new(Enum.at(row, 0))
      |> Article.set_headline(Enum.at(row, 0))
      |> Article.set_type(Enum.at(row, 4))
      |> Article.set_content(Enum.at(row, 5))
      |> Article.set_author(Enum.at(row, 6))
      |> Article.set_veracity(false)
    ]
  end

  @doc """
  Convert list of articles into a map with the card id and veracity as its key
  """
  def create_store(articles) do
    articles
    |> Enum.reduce(%{}, fn el, acc -> Map.put(acc, {el.card_id, el.veracity}, el) end)
  end

  def get_article_by_card(article_store, %Sparse{} = card) do
    article_store[{card.id, card.veracity}]
  end
end
