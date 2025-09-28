class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # 1) For the checkboxes
    @all_ratings = Movie.all_ratings

    # ---- Read current params (if any) ----
    ratings_from_params = params[:ratings]&.keys
    allowed_sorts       = %w[title release_date]
    sort_from_params    = params[:sort_by] if allowed_sorts.include?(params[:sort_by])

    # 2) Resolve ratings to show:
    #    - if params has ratings: use it (and save to session)
    #    - else if session has ratings: use session
    #    - else default to "all selected"
    if ratings_from_params.present?
      @ratings_to_show   = ratings_from_params
      session[:ratings]  = @ratings_to_show
    elsif session[:ratings].present?
      @ratings_to_show   = session[:ratings]
    else
      @ratings_to_show   = @all_ratings
      session[:ratings]  = @ratings_to_show
    end

    # 3) Resolve sort_by similarly
    if sort_from_params.present?
      @sort_by           = sort_from_params
      session[:sort_by]  = @sort_by
    elsif session[:sort_by].present?
      @sort_by           = session[:sort_by]
    else
      @sort_by           = nil
    end

    # 4) Keep URL RESTful:
    #    If params miss any piece that we do have in session, redirect to a URL
    #    that contains those pieces explicitly.
    need_redirect  = false
    redirect_args  = {}

    unless params[:ratings].present?
      if session[:ratings].present?
        need_redirect = true
        redirect_args[:ratings] = session[:ratings].index_with { '1' }  # ["G","R"] => {"G"=>"1","R"=>"1"}
      end
    end

    unless params[:sort_by].present?
      if session[:sort_by].present?
        need_redirect = true
        redirect_args[:sort_by] = session[:sort_by]
      end
    end

    if need_redirect
      flash.keep
      return redirect_to movies_path(redirect_args)
    end

    # 5) Query: filter then sort
    @movies = Movie.with_ratings(@ratings_to_show)
    @movies = @movies.sorted_by(@sort_by) if @sort_by.present?
  end


  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
