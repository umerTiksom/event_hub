
class Api::V1::EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_event, only: [:show, :update, :destroy]

  def index
    events = Event.includes(:category)

    # Search by event name or description
    if params[:search].present?
      search_term = "%#{Event.sanitize_sql_like(params[:search])}%"

      events = events.where(
        "events.name ILIKE :term OR events.description ILIKE :term",
        term: search_term
      )
    end

    # Filter by category name
    if params[:category].present?
      events = events.joins(:category)
                     .where(categories: { name: params[:category] })
    end

    #  Filter by location
    if params[:location].present?
      location_term = "%#{Event.sanitize_sql_like(params[:location])}%"

      events = events.where(
        "events.location ILIKE ?",
        location_term
      )
    end

    # Pagination using will_paginate
    page = params[:page].to_i
    page = 1 if page < 1

    events = events.paginate(page: page, per_page: 10)

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

  rescue Date::Error, ArgumentError
    render json: {
      status: "error",
      message: "Invalid date. Use YYYY-MM-DD format."
    }, status: :unprocessable_entity
  end

  def show
    render json: {
      status: "success",
      data: @event.as_json(include: :category)
    }, status: :ok
  end

  def create
    event = Event.new(event_params)

    if event.save
      render json: {
        status: "success",
        message: "Event created successfully",
        data: event
      }, status: :created
    else
      render json: {
        status: "error",
        errors: event.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(event_params)
      render json: {
        status: "success",
        message: "Event updated successfully",
        data: @event
      }, status: :ok
    else
      render json: {
        status: "error",
        errors: @event.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy

    render json: {
      status: "success",
      message: "Event deleted successfully"
    }, status: :ok
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
      :desc,
      :location,
      :start_time,
      :category_id
    )
  end
end
