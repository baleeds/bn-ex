alias Nota.Repo
alias Nota.Annotations.Annotation
alias Nota.Auth.User

query = "copy verses(id, book_number, chapter_number, verse_number, text) from 'C:\\Code\\nota-api\\priv\\repo\\data\\t_web.csv' DELIMITER ',' CSV HEADER;"
Ecto.Adapters.SQL.query(Repo, query)

luke = Repo.insert!(%User{
  email: "luke@nota.com",
  first_name: "Luke",
  last_name: "Skywalker"
})

yoda = Repo.insert!(%User{
  email: "yoda@nota.com",
  first_name: "Master",
  last_name: "Yoda",
})

Repo.insert!(%Annotation{
  text: "<p>First annotation</p>",
  verse_id: 01001001,
  user_id: luke.id
})

Repo.insert!(%Annotation{
  text: "<p>Second annotation</p>",
  verse_id: 01001001,
  user_id: yoda.id
})