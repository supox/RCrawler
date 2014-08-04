class AdjustmentsController < ApplicationController
  before_action :set_adjustment, only: [:show, :edit, :update, :destroy]

  def index
    @adjustments = Adjustment.paginate(:per_page => (params[:per_page] || 25), :page => params[:page])
  end

  def show
  end

  def new
    @adjustment = Adjustment.new
  end

  def edit
  end

  def create
    @adjustment = Adjustment.new(adjustment_params)

    respond_to do |format|
      if @adjustment.save
        format.html { redirect_to @adjustment, notice: 'Adjustment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @adjustment }
      else
        format.html { render action: 'new' }
        format.json { render json: @adjustment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @adjustment.update(adjustment_params)
        format.html { redirect_to @adjustment, notice: 'Adjustment was successfully updated.' }
        format.js 
      else
        format.html { render action: 'edit' }
        format.json { render json: @adjustment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @adjustment.destroy
    respond_to do |format|
      format.html { redirect_to adjustments_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_adjustment
      @adjustment = Adjustment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def adjustment_params
      params.require(:adjustment).permit(:weight, :color, :clarity, :cut_vg, :cut_g, :sym_vg, :sym_g, :pol_vg, :pol_g, :flor_faint, :flor_medium, :flor_strong)
    end
end
