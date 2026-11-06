class Api::V1::EventsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_event, only: %i[show update destroy]

  def index
    cache_key = [
      "events",
      "v1",
      "search:#{params[:search]}",
      "category:#{params[:category]}",
      "location:#{params[:location]}",
      "page:#{params[:page] || 1}",
      "per_page:12"
    ].join("/")

    response_data = Rails.cache.fetch(
      cache_key,
      expires_in: 5.minutes
    ) do
      events = policy_scope(Event)

      events = Event.filter_events(
        events,
        search: params[:search],
        category: params[:category],
        location: params[:location]
      )

      events = Event.paginate_events(
        events,
        page: params[:page],
        per_page: 12
      )

      {
        status: "success",
        data: events.as_json(include: :category),
        pagination: {
          current_page: events.current_page,
          per_page: events.per_page,
          total_count: events.total_entries,
          total_pages: events.total_pages,
          next_page: events.next_page,
          previous_page: events.previous_page
        }
      }
    end

    render json: response_data, status: :ok
  end

  def show
    authorize @event, :show?

    render json: {
      status: "success",
      data: @event.as_json(include: :category)
    }, status: :ok
  end

  def create
    event = Event.new(event_params)
    event.user = current_user

    authorize event, :create?

    if event.save
      render json: {
        status: "success",
        message: "Event created successfully",
        data: event.as_json(include: :category)
      }, status: :created
    else
      render json: {
        status: "error",
        errors: event.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    authorize @event, :update?

    if @event.update(event_params)
      render json: {
        status: "success",
        message: "Event updated successfully!",
        data: @event.as_json(include: :category)
      }, status: :ok
    else
      render json: {
        status: "error",
        message: "Event update failed",
        errors: @event.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @event, :destroy?

    @event.destroy!

    head :no_content
  end

  private

  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: "error",
      message: "Event not found"
    }, status: :not_found
  end

  def event_params
    params.require(:event).permit(
      :name,
      :description,
      :location,
      :category_id,
      :date
    )
  end
end
