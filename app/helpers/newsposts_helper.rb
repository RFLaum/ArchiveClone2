module NewspostsHelper
  def news_tag_path(tag)
    newsposts_path + '?tag=' + tag.name
  end
end
