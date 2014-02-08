class DiamondsController < ApplicationController
  before_action :set_diamond, only: [:show, :edit, :update, :destroy]

  # GET /diamonds
  # GET /diamonds.json
  def index
    @search_params = params[:search] ? search_params : nil
    @search = Diamond.new(@search_params)
    @diamonds = Diamond.search(@search_params).paginate(:per_page => 25, :page => params[:page])
  end

  # GET /diamonds/1
  # GET /diamonds/1.json
  def show
  end

  # GET /diamonds/new
  def new
    @diamond = Diamond.new
  end

  # GET /diamonds/1/edit
  def edit
  end

  # POST /diamonds
  # POST /diamonds.json
  def create
    @diamond = Diamond.new(diamond_params)

    respond_to do |format|
      if @diamond.save
        format.html { redirect_to @diamond, notice: 'Diamond was successfully created.' }
        format.json { render action: 'show', status: :created, location: @diamond }
      else
        format.html { render action: 'new' }
        format.json { render json: @diamond.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diamonds/1
  # PATCH/PUT /diamonds/1.json
  def update
    respond_to do |format|
      if @diamond.update(diamond_params)
        format.html { redirect_to @diamond, notice: 'Diamond was successfully updated.' }
        format.json { render action: 'show', status: :ok, location: @diamond }
      else
        format.html { render action: 'edit' }
        format.json { render json: @diamond.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diamonds/1
  # DELETE /diamonds/1.json
  def destroy
    @diamond.destroy
    respond_to do |format|
      format.html { redirect_to diamonds_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diamond
      @diamond = Diamond.find(params[:id])
    end

    def search_params
      params.require(:search).permit(:shape, :size, :color, :clarity, :cut, :polish, :sym, :flour)
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def diamond_params
      params.require(:diamond).permit(:shape, :size, :color, :clarity, :cut, :polish, :sym, :flour, :number_of_results, :rap_percentage)
    end
end
