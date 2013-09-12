class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_ref

  def index
    begin
      @documents = api.form("everything").submit(@ref)
      render inline: JSON.pretty_generate(@documents)
    rescue Prismic::SearchForm::RefNotFoundException => e
      render inline: e.message, :status => :not_found
    end
  end

  def document
    id = params[:id]
    slug = params[:slug]

    @document = PrismicService.get_document(id, api, @ref)
    if @document.nil?
      render inline: "Document not found", status: :not_found
    end

    if slug == @document.slug
      @document
    elsif document.slugs.contains(slug)
      redirect_to document_application_path(id, slug), status: :moved_permanently
    else
      render inline: "Slug not found", status: :not_found
    end
  end

  private

  def set_ref
    @ref = params[:ref] || api.ref_id_by_label('Master').ref
  end

  def api
    @api ||= PrismicService.init_api
  end
end