json.extract! newspost, :id, :admin_name, :title, :content, :created_at, :updated_at
json.url newspost_url(newspost, format: :json)
