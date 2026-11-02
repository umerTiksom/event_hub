
# frozen_string_literal: true

class Api::V1::EventsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_event, only: %i[show update destroy]

  def index
    events = policy_scope(Event).includes(:category)

    events = search_events(events)
    events = filter_by_category(events)
    events = filter_by_location(events)

    page = [params[:page].to_i, 1].max
    per_page = 10

    events = events.paginate(page: page, per_page: per_page)

    render json: {
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
    }, status: :ok
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

  def search_events(events)
    return events unless params[:search].present?

    search_term = "%#{Event.sanitize_sql_like(params[:search])}%"

    events.where(
      "events.name ILIKE :term OR events.description ILIKE :term",
      term: search_term
    )
  end

  def filter_by_category(events)
    return events unless params[:category].present? && params[:category] != "All"

    events.joins(:category)
          .where(categories: { name: params[:category] })
  end

  def filter_by_location(events)
    return events unless params[:location].present?

    location_term = "%#{Event.sanitize_sql_like(params[:location])}%"

    events.where("events.location ILIKE ?", location_term)
  end
end
