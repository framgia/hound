class RepoSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :github_id,
    :active,
    :full_github_name,
    :private,
    :in_organization,
    :price
  )
end
