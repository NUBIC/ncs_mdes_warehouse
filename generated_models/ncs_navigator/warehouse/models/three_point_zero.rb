module NcsNavigator
  module Warehouse
    module Models
      module ThreePointZero
        extend NcsNavigator::Warehouse::Models::MdesModelCollection
      end
    end
  end
end

require 'ncs_navigator/warehouse/models/three_point_zero/study_center'
require 'ncs_navigator/warehouse/models/three_point_zero/psu'
require 'ncs_navigator/warehouse/models/three_point_zero/ssu'
require 'ncs_navigator/warehouse/models/three_point_zero/tsu'
require 'ncs_navigator/warehouse/models/three_point_zero/listing_unit'
require 'ncs_navigator/warehouse/models/three_point_zero/dwelling_unit'
require 'ncs_navigator/warehouse/models/three_point_zero/household_unit'
require 'ncs_navigator/warehouse/models/three_point_zero/link_household_dwelling'
require 'ncs_navigator/warehouse/models/three_point_zero/staff'
require 'ncs_navigator/warehouse/models/three_point_zero/staff_language'
require 'ncs_navigator/warehouse/models/three_point_zero/staff_validation'
require 'ncs_navigator/warehouse/models/three_point_zero/staff_weekly_expense'
require 'ncs_navigator/warehouse/models/three_point_zero/staff_exp_mngmnt_tasks'
require 'ncs_navigator/warehouse/models/three_point_zero/staff_exp_data_cllctn_tasks'
require 'ncs_navigator/warehouse/models/three_point_zero/outreach'
require 'ncs_navigator/warehouse/models/three_point_zero/outreach_race'
require 'ncs_navigator/warehouse/models/three_point_zero/outreach_staff'
require 'ncs_navigator/warehouse/models/three_point_zero/outreach_eval'
require 'ncs_navigator/warehouse/models/three_point_zero/outreach_target'
require 'ncs_navigator/warehouse/models/three_point_zero/outreach_lang2'
require 'ncs_navigator/warehouse/models/three_point_zero/staff_cert_training'
require 'ncs_navigator/warehouse/models/three_point_zero/person'
require 'ncs_navigator/warehouse/models/three_point_zero/person_race'
require 'ncs_navigator/warehouse/models/three_point_zero/link_person_household'
require 'ncs_navigator/warehouse/models/three_point_zero/participant'
require 'ncs_navigator/warehouse/models/three_point_zero/link_person_participant'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_auth'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_consent'
require 'ncs_navigator/warehouse/models/three_point_zero/ppg_details'
require 'ncs_navigator/warehouse/models/three_point_zero/ppg_status_history'
require 'ncs_navigator/warehouse/models/three_point_zero/provider'
require 'ncs_navigator/warehouse/models/three_point_zero/provider_role'
require 'ncs_navigator/warehouse/models/three_point_zero/link_person_provider'
require 'ncs_navigator/warehouse/models/three_point_zero/institution'
require 'ncs_navigator/warehouse/models/three_point_zero/link_person_institute'
require 'ncs_navigator/warehouse/models/three_point_zero/address'
require 'ncs_navigator/warehouse/models/three_point_zero/telephone'
require 'ncs_navigator/warehouse/models/three_point_zero/email'
require 'ncs_navigator/warehouse/models/three_point_zero/event'
require 'ncs_navigator/warehouse/models/three_point_zero/instrument'
require 'ncs_navigator/warehouse/models/three_point_zero/contact'
require 'ncs_navigator/warehouse/models/three_point_zero/link_contact'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_rpt'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_rpt_vacant'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_rpt_noaccess'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_rpt_refusal'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_rpt_dutype'
require 'ncs_navigator/warehouse/models/three_point_zero/incident'
require 'ncs_navigator/warehouse/models/three_point_zero/incident_media'
require 'ncs_navigator/warehouse/models/three_point_zero/incident_unanticipated'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_equipment'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_pickup'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_receipt'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_shipping'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_storage'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_spsc_info'
require 'ncs_navigator/warehouse/models/three_point_zero/env_equipment'
require 'ncs_navigator/warehouse/models/three_point_zero/env_equipment_prob_log'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_consent_sample'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_rvis'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_vis_consent'
require 'ncs_navigator/warehouse/models/three_point_zero/prec_therm_cert'
require 'ncs_navigator/warehouse/models/three_point_zero/ref_freezer_verification'
require 'ncs_navigator/warehouse/models/three_point_zero/sample_receipt_store'
require 'ncs_navigator/warehouse/models/three_point_zero/sample_shipping'
require 'ncs_navigator/warehouse/models/three_point_zero/srsc_info'
require 'ncs_navigator/warehouse/models/three_point_zero/subsample_doc'
require 'ncs_navigator/warehouse/models/three_point_zero/trh_meter_calibration'
require 'ncs_navigator/warehouse/models/three_point_zero/drf_therm_verification'
require 'ncs_navigator/warehouse/models/three_point_zero/sample_receipt_confirm'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_consent_reconsideration'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_list'
require 'ncs_navigator/warehouse/models/three_point_zero/sampled_persons_ineligibility'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_screening_performed'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_provider'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_provider_refusal'
require 'ncs_navigator/warehouse/models/three_point_zero/provider_role_pbs'
require 'ncs_navigator/warehouse/models/three_point_zero/provider_logistics'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_baby_name'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_decorate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_renovate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_2'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_baby_name_2'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_decorate_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_renovate_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_baby_name_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_decorate_room_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_diagnose_2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_baby_ethnic_origin_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_household_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_baby_race_1_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_baby_race_2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_baby_race_3_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_baby_race_new_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_renovate_room_3'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_li'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_li_baby_name'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_li_decorate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/birth_visit_li_renovate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_cond'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_detail'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_habits'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_lice'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_mold'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_pet_type'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_renovate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_room_mold'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_prescr'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_otc'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_suppl'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_detail_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_habits_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_lice_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_mold_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_pet_type_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_renovate_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_room_mold_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_prescr_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_otc_2'
require 'ncs_navigator/warehouse/models/three_point_zero/eighteen_mth_mother_suppl_2'
require 'ncs_navigator/warehouse/models/three_point_zero/father_pv1'
require 'ncs_navigator/warehouse/models/three_point_zero/father_pv1_cancer'
require 'ncs_navigator/warehouse/models/three_point_zero/father_pv1_educ'
require 'ncs_navigator/warehouse/models/three_point_zero/father_pv1_race'
require 'ncs_navigator/warehouse/models/three_point_zero/father_pv1_2'
require 'ncs_navigator/warehouse/models/three_point_zero/father_pv1_cancer_2'
require 'ncs_navigator/warehouse/models/three_point_zero/father_pv1_race_2'
require 'ncs_navigator/warehouse/models/three_point_zero/household_enumeration'
require 'ncs_navigator/warehouse/models/three_point_zero/household_enumeration_age_elig'
require 'ncs_navigator/warehouse/models/three_point_zero/household_enumeration_hidden_du'
require 'ncs_navigator/warehouse/models/three_point_zero/household_enumeration_pregnant'
require 'ncs_navigator/warehouse/models/three_point_zero/household_inventory'
require 'ncs_navigator/warehouse/models/three_point_zero/household_inventory_age'
require 'ncs_navigator/warehouse/models/three_point_zero/household_inventory_age_elig'
require 'ncs_navigator/warehouse/models/three_point_zero/internet_usage'
require 'ncs_navigator/warehouse/models/three_point_zero/internet_usage_participate'
require 'ncs_navigator/warehouse/models/three_point_zero/low_high_script'
require 'ncs_navigator/warehouse/models/three_point_zero/multi_mode'
require 'ncs_navigator/warehouse/models/three_point_zero/nine_mth_mother'
require 'ncs_navigator/warehouse/models/three_point_zero/nine_mth_mother_detail'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_respondent'
require 'ncs_navigator/warehouse/models/three_point_zero/non_interview_respondent_influ'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_verif'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_verif_child'
require 'ncs_navigator/warehouse/models/three_point_zero/participant_verif_diff'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_recruitment'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_recruitment_info_source'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_recruitment_prov_source'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_recruitment_prov_svc'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_recruitment_2'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_recruitment_info_source_2'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_recruitment_prov_source_2'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_recruitment_prov_svc_2'
require 'ncs_navigator/warehouse/models/three_point_zero/pb_samp_frame'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_day1'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_day2'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_employ'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_ethnic_origin_2'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_pr_office'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_race_1'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_race_2'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_race_3'
require 'ncs_navigator/warehouse/models/three_point_zero/pbs_elig_screener_race_new'
require 'ncs_navigator/warehouse/models/three_point_zero/ppg_cati'
require 'ncs_navigator/warehouse/models/three_point_zero/ppg_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_preg'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_preg_cool'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_preg_heat2'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_preg_pdecorate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_preg_prenovate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_preg_room_mold'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_preg_sp_race'
require 'ncs_navigator/warehouse/models/three_point_zero/pre_preg_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_eh'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_eh_know_ncs'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_eh_race'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_eh_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_eh_know_ncs_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_eh_race_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_hi'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_hi_know_ncs'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_hi_race'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_hi_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_hi_know_ncs_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_hi_race_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_pb'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_pb_know_ncs'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_pb_race'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_pb_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_pb_know_ncs_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_screen_pb_race_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_commute'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_cool'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_diagnose_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_heat2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_local_trav'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_pdecorate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_pet_type'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_prenovate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_prenovate2_room'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_room_mold'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_sp_race'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_commute_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_cool_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_diagnose_2_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_heat2_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_local_trav_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_nonenglish2_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_pdecorate_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_pet_type_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_prenovate_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_room_mold_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_sp_race_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_commute_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_cool_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_ethnic_origin_2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_heat2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_local_trav_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_pdecorate_room_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_pet_type_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_prenovate_room_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_race_1_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_race_2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_race_3_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_race_new_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_room_mold_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_sp_ethnic_2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_sp_race_1_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_sp_race_2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_sp_race_3_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_sp_race_new_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_saq_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_saq_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_1_saq_4'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_cool'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_diagnose_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_heat2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_pdecorate2_room'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_prenovate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_room_mold'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_cool_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_diagnose_2_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_heat2_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_pdecorate2_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_prenovate_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_room_mold_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_cool_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_diagnose_2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_heat2_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_pdecorate2_room_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_prenovate_room_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_room_mold_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_saq_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_saq_3'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_2_saq_4'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_li'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_li_cool'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_li_2'
require 'ncs_navigator/warehouse/models/three_point_zero/preg_visit_li_cool_2'
require 'ncs_navigator/warehouse/models/three_point_zero/sample_dist'
require 'ncs_navigator/warehouse/models/three_point_zero/sample_dist_samp'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_mother'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_mother_detail'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_mother_pet'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_formula_type'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_supp'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_water'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_2'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_formula_type_2'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_supp_2'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_water_2'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_3'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_formula_type_3'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_supp_3'
require 'ncs_navigator/warehouse/models/three_point_zero/six_mth_saq_water_3'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_draw'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_hemolyze'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_tube_comments'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_tube'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_2'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_draw_2'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_hemolyze_2'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_tube_comments_2'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_blood_tube_2'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_cord_blood'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_cord_blood_specimen'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_cord_blood_2'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_cord_blood_specimen_2'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_cord_blood_3'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_cord_blood_specimen_3'
require 'ncs_navigator/warehouse/models/three_point_zero/spec_urine'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_blank_collected'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_dup_collected'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_dup_filled'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_n_collected'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_reason_filled'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_reason_filled2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_sample'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_subsamples'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_saq_eat'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_saq_prob'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_blank_collected_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_dup_collected_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_dup_filled_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_n_collected_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_reason_filled_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_reason_filled2_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_sample_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twf_subsamples_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_blank_collected'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_dup_collected'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_dup_filled'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_n_collected'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_reason_filled'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_reason_filled2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_sample'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_subsamples'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_saq_prob'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_blank_collected_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_dup_collected_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_dup_filled_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_n_collected_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_reason_filled_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_reason_filled2_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_sample_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tap_water_twq_subsamples_2'
require 'ncs_navigator/warehouse/models/three_point_zero/three_mth_mother'
require 'ncs_navigator/warehouse/models/three_point_zero/three_mth_mother_child_detail'
require 'ncs_navigator/warehouse/models/three_point_zero/three_mth_mother_child_habits'
require 'ncs_navigator/warehouse/models/three_point_zero/three_mth_mother_race'
require 'ncs_navigator/warehouse/models/three_point_zero/three_mth_mother_2'
require 'ncs_navigator/warehouse/models/three_point_zero/three_mth_mother_child_detail_2'
require 'ncs_navigator/warehouse/models/three_point_zero/three_mth_mother_child_habits_2'
require 'ncs_navigator/warehouse/models/three_point_zero/three_mth_mother_race_2'
require 'ncs_navigator/warehouse/models/three_point_zero/tracing_int'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_detail'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_lice'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_renovate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_room_mold'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_detail_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_lice_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_renovate_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_mother_room_mold_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_formula_brand'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_formula_type'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_supplement'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_water'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_formula_brand_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_formula_type_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_supplement_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twelve_mth_saq_water_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_cond'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_detail'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_habits'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_mold'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_pet_type'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_renovate_room'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_room_mold'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_prescr'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_otc'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_suppl'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_detail_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_habits_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_mold_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_otc_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_prescr_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_mother_suppl_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_pet_type_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_renovate_room_2'
require 'ncs_navigator/warehouse/models/three_point_zero/twenty_four_mth_room_mold_2'
require 'ncs_navigator/warehouse/models/three_point_zero/vacuum_bag'
require 'ncs_navigator/warehouse/models/three_point_zero/vacuum_bag_outside'
require 'ncs_navigator/warehouse/models/three_point_zero/vacuum_bag_2'
require 'ncs_navigator/warehouse/models/three_point_zero/vacuum_bag_outside_2'
require 'ncs_navigator/warehouse/models/three_point_zero/vacuum_bag_saq'
require 'ncs_navigator/warehouse/models/three_point_zero/vacuum_bag_saq_outside'
require 'ncs_navigator/warehouse/models/three_point_zero/vacuum_bag_saq_prob'
require 'ncs_navigator/warehouse/models/three_point_zero/validation_ins'

module NcsNavigator
  module Warehouse
    module Models
      module ThreePointZero
        mdes_version "3.0"
        mdes_specification_version "3.0.00.09"
        mdes_order StudyCenter,
          Psu,
          Ssu,
          Tsu,
          ListingUnit,
          DwellingUnit,
          HouseholdUnit,
          LinkHouseholdDwelling,
          Staff,
          StaffLanguage,
          StaffValidation,
          StaffWeeklyExpense,
          StaffExpMngmntTasks,
          StaffExpDataCllctnTasks,
          Outreach,
          OutreachRace,
          OutreachStaff,
          OutreachEval,
          OutreachTarget,
          OutreachLang2,
          StaffCertTraining,
          Person,
          PersonRace,
          LinkPersonHousehold,
          Participant,
          LinkPersonParticipant,
          ParticipantAuth,
          ParticipantConsent,
          PpgDetails,
          PpgStatusHistory,
          Provider,
          ProviderRole,
          LinkPersonProvider,
          Institution,
          LinkPersonInstitute,
          Address,
          Telephone,
          Email,
          Event,
          Instrument,
          Contact,
          LinkContact,
          NonInterviewRpt,
          NonInterviewRptVacant,
          NonInterviewRptNoaccess,
          NonInterviewRptRefusal,
          NonInterviewRptDutype,
          Incident,
          IncidentMedia,
          IncidentUnanticipated,
          SpecEquipment,
          SpecPickup,
          SpecReceipt,
          SpecShipping,
          SpecStorage,
          SpecSpscInfo,
          EnvEquipment,
          EnvEquipmentProbLog,
          ParticipantConsentSample,
          ParticipantRvis,
          ParticipantVisConsent,
          PrecThermCert,
          RefFreezerVerification,
          SampleReceiptStore,
          SampleShipping,
          SrscInfo,
          SubsampleDoc,
          TrhMeterCalibration,
          DrfThermVerification,
          SampleReceiptConfirm,
          ParticipantConsentReconsideration,
          PbsList,
          SampledPersonsIneligibility,
          PreScreeningPerformed,
          NonInterviewProvider,
          NonInterviewProviderRefusal,
          ProviderRolePbs,
          ProviderLogistics,
          BirthVisit,
          BirthVisitBabyName,
          BirthVisitDecorateRoom,
          BirthVisitRenovateRoom,
          BirthVisit_2,
          BirthVisitBabyName_2,
          BirthVisitDecorateRoom_2,
          BirthVisitRenovateRoom_2,
          BirthVisit_3,
          BirthVisitBabyName_3,
          BirthVisitDecorateRoom_3,
          BirthVisitDiagnose_2_3,
          BirthVisitBabyEthnicOrigin_3,
          BirthVisitHousehold_3,
          BirthVisitBabyRace_1_3,
          BirthVisitBabyRace_2_3,
          BirthVisitBabyRace_3_3,
          BirthVisitBabyRaceNew_3,
          BirthVisitRenovateRoom_3,
          BirthVisitLi,
          BirthVisitLiBabyName,
          BirthVisitLiDecorateRoom,
          BirthVisitLiRenovateRoom,
          EighteenMthMother,
          EighteenMthMotherCond,
          EighteenMthMotherDetail,
          EighteenMthMotherHabits,
          EighteenMthMotherLice,
          EighteenMthMotherMold,
          EighteenMthMotherPetType,
          EighteenMthMotherRenovateRoom,
          EighteenMthMotherRoomMold,
          EighteenMthMotherPrescr,
          EighteenMthMotherOtc,
          EighteenMthMotherSuppl,
          EighteenMthMotherSaq,
          EighteenMthMother_2,
          EighteenMthMotherDetail_2,
          EighteenMthMotherHabits_2,
          EighteenMthMotherLice_2,
          EighteenMthMotherMold_2,
          EighteenMthMotherPetType_2,
          EighteenMthMotherRenovateRoom_2,
          EighteenMthMotherRoomMold_2,
          EighteenMthMotherPrescr_2,
          EighteenMthMotherOtc_2,
          EighteenMthMotherSuppl_2,
          FatherPv1,
          FatherPv1Cancer,
          FatherPv1Educ,
          FatherPv1Race,
          FatherPv1_2,
          FatherPv1Cancer_2,
          FatherPv1Race_2,
          HouseholdEnumeration,
          HouseholdEnumerationAgeElig,
          HouseholdEnumerationHiddenDu,
          HouseholdEnumerationPregnant,
          HouseholdInventory,
          HouseholdInventoryAge,
          HouseholdInventoryAgeElig,
          InternetUsage,
          InternetUsageParticipate,
          LowHighScript,
          MultiMode,
          NineMthMother,
          NineMthMotherDetail,
          NonInterviewRespondent,
          NonInterviewRespondentInflu,
          ParticipantVerif,
          ParticipantVerifChild,
          ParticipantVerifDiff,
          PbRecruitment,
          PbRecruitmentInfoSource,
          PbRecruitmentProvSource,
          PbRecruitmentProvSvc,
          PbRecruitment_2,
          PbRecruitmentInfoSource_2,
          PbRecruitmentProvSource_2,
          PbRecruitmentProvSvc_2,
          PbSampFrame,
          PbsEligScreener,
          PbsEligScreenerDay1,
          PbsEligScreenerDay2,
          PbsEligScreenerEmploy,
          PbsEligScreenerEthnicOrigin_2,
          PbsEligScreenerPrOffice,
          PbsEligScreenerRace_1,
          PbsEligScreenerRace_2,
          PbsEligScreenerRace_3,
          PbsEligScreenerRaceNew,
          PpgCati,
          PpgSaq,
          PrePreg,
          PrePregCool,
          PrePregHeat2,
          PrePregPdecorateRoom,
          PrePregPrenovateRoom,
          PrePregRoomMold,
          PrePregSpRace,
          PrePregSaq,
          PregScreenEh,
          PregScreenEhKnowNcs,
          PregScreenEhRace,
          PregScreenEh_2,
          PregScreenEhKnowNcs_2,
          PregScreenEhRace_2,
          PregScreenHi,
          PregScreenHiKnowNcs,
          PregScreenHiRace,
          PregScreenHi_2,
          PregScreenHiKnowNcs_2,
          PregScreenHiRace_2,
          PregScreenPb,
          PregScreenPbKnowNcs,
          PregScreenPbRace,
          PregScreenPb_2,
          PregScreenPbKnowNcs_2,
          PregScreenPbRace_2,
          PregVisit_1,
          PregVisit1Commute,
          PregVisit1Cool,
          PregVisit1Diagnose_2,
          PregVisit1Heat2,
          PregVisit1LocalTrav,
          PregVisit1PdecorateRoom,
          PregVisit1PetType,
          PregVisit1PrenovateRoom,
          PregVisit1Prenovate2Room,
          PregVisit1RoomMold,
          PregVisit1SpRace,
          PregVisit_1_2,
          PregVisit1Commute_2,
          PregVisit1Cool_2,
          PregVisit1Diagnose_2_2,
          PregVisit1Heat2_2,
          PregVisit1LocalTrav_2,
          PregVisit1Nonenglish2_2,
          PregVisit1PdecorateRoom_2,
          PregVisit1PetType_2,
          PregVisit1PrenovateRoom_2,
          PregVisit1RoomMold_2,
          PregVisit1SpRace_2,
          PregVisit_1_3,
          PregVisit1Commute_3,
          PregVisit1Cool_3,
          PregVisit1EthnicOrigin_2_3,
          PregVisit1Heat2_3,
          PregVisit1LocalTrav_3,
          PregVisit1PdecorateRoom_3,
          PregVisit1PetType_3,
          PregVisit1PrenovateRoom_3,
          PregVisit1Race_1_3,
          PregVisit1Race_2_3,
          PregVisit1Race_3_3,
          PregVisit1RaceNew_3,
          PregVisit1RoomMold_3,
          PregVisit1SpEthnic_2_3,
          PregVisit1SpRace_1_3,
          PregVisit1SpRace_2_3,
          PregVisit1SpRace_3_3,
          PregVisit1SpRaceNew_3,
          PregVisit1Saq,
          PregVisit1Saq_2,
          PregVisit1Saq_3,
          PregVisit1Saq_4,
          PregVisit_2,
          PregVisit2Cool,
          PregVisit2Diagnose_2,
          PregVisit2Heat2,
          PregVisit2Pdecorate2Room,
          PregVisit2PrenovateRoom,
          PregVisit2RoomMold,
          PregVisit_2_2,
          PregVisit2Cool_2,
          PregVisit2Diagnose_2_2,
          PregVisit2Heat2_2,
          PregVisit2Pdecorate2Room_2,
          PregVisit2PrenovateRoom_2,
          PregVisit2RoomMold_2,
          PregVisit_2_3,
          PregVisit2Cool_3,
          PregVisit2Diagnose_2_3,
          PregVisit2Heat2_3,
          PregVisit2Pdecorate2Room_3,
          PregVisit2PrenovateRoom_3,
          PregVisit2RoomMold_3,
          PregVisit2Saq,
          PregVisit2Saq_2,
          PregVisit2Saq_3,
          PregVisit2Saq_4,
          PregVisitLi,
          PregVisitLiCool,
          PregVisitLi_2,
          PregVisitLiCool_2,
          SampleDist,
          SampleDistSamp,
          SixMthMother,
          SixMthMotherDetail,
          SixMthMotherPet,
          SixMthSaq,
          SixMthSaqFormulaType,
          SixMthSaqSupp,
          SixMthSaqWater,
          SixMthSaq_2,
          SixMthSaqFormulaType_2,
          SixMthSaqSupp_2,
          SixMthSaqWater_2,
          SixMthSaq_3,
          SixMthSaqFormulaType_3,
          SixMthSaqSupp_3,
          SixMthSaqWater_3,
          SpecBlood,
          SpecBloodDraw,
          SpecBloodHemolyze,
          SpecBloodTubeComments,
          SpecBloodTube,
          SpecBlood_2,
          SpecBloodDraw_2,
          SpecBloodHemolyze_2,
          SpecBloodTubeComments_2,
          SpecBloodTube_2,
          SpecCordBlood,
          SpecCordBloodSpecimen,
          SpecCordBlood_2,
          SpecCordBloodSpecimen_2,
          SpecCordBlood_3,
          SpecCordBloodSpecimen_3,
          SpecUrine,
          TapWaterTwf,
          TapWaterTwfBlankCollected,
          TapWaterTwfDupCollected,
          TapWaterTwfDupFilled,
          TapWaterTwfNCollected,
          TapWaterTwfReasonFilled,
          TapWaterTwfReasonFilled2,
          TapWaterTwfSample,
          TapWaterTwfSubsamples,
          TapWaterTwfSaq,
          TapWaterTwfSaqEat,
          TapWaterTwfSaqProb,
          TapWaterTwf_2,
          TapWaterTwfBlankCollected_2,
          TapWaterTwfDupCollected_2,
          TapWaterTwfDupFilled_2,
          TapWaterTwfNCollected_2,
          TapWaterTwfReasonFilled_2,
          TapWaterTwfReasonFilled2_2,
          TapWaterTwfSample_2,
          TapWaterTwfSubsamples_2,
          TapWaterTwq,
          TapWaterTwqBlankCollected,
          TapWaterTwqDupCollected,
          TapWaterTwqDupFilled,
          TapWaterTwqNCollected,
          TapWaterTwqReasonFilled,
          TapWaterTwqReasonFilled2,
          TapWaterTwqSample,
          TapWaterTwqSubsamples,
          TapWaterTwqSaq,
          TapWaterTwqSaqProb,
          TapWaterTwq_2,
          TapWaterTwqBlankCollected_2,
          TapWaterTwqDupCollected_2,
          TapWaterTwqDupFilled_2,
          TapWaterTwqNCollected_2,
          TapWaterTwqReasonFilled_2,
          TapWaterTwqReasonFilled2_2,
          TapWaterTwqSample_2,
          TapWaterTwqSubsamples_2,
          ThreeMthMother,
          ThreeMthMotherChildDetail,
          ThreeMthMotherChildHabits,
          ThreeMthMotherRace,
          ThreeMthMother_2,
          ThreeMthMotherChildDetail_2,
          ThreeMthMotherChildHabits_2,
          ThreeMthMotherRace_2,
          TracingInt,
          TwelveMthMother,
          TwelveMthMotherDetail,
          TwelveMthMotherLice,
          TwelveMthMotherRenovateRoom,
          TwelveMthMotherRoomMold,
          TwelveMthMother_2,
          TwelveMthMotherDetail_2,
          TwelveMthMotherLice_2,
          TwelveMthMotherRenovateRoom_2,
          TwelveMthMotherRoomMold_2,
          TwelveMthSaq,
          TwelveMthSaqFormulaBrand,
          TwelveMthSaqFormulaType,
          TwelveMthSaqSupplement,
          TwelveMthSaqWater,
          TwelveMthSaq_2,
          TwelveMthSaqFormulaBrand_2,
          TwelveMthSaqFormulaType_2,
          TwelveMthSaqSupplement_2,
          TwelveMthSaqWater_2,
          TwentyFourMthMother,
          TwentyFourMthMotherCond,
          TwentyFourMthMotherDetail,
          TwentyFourMthMotherHabits,
          TwentyFourMthMotherMold,
          TwentyFourMthPetType,
          TwentyFourMthRenovateRoom,
          TwentyFourMthRoomMold,
          TwentyFourMthMotherPrescr,
          TwentyFourMthMotherOtc,
          TwentyFourMthMotherSuppl,
          TwentyFourMthSaq,
          TwentyFourMthMother_2,
          TwentyFourMthMotherDetail_2,
          TwentyFourMthMotherHabits_2,
          TwentyFourMthMotherMold_2,
          TwentyFourMthMotherOtc_2,
          TwentyFourMthMotherPrescr_2,
          TwentyFourMthMotherSuppl_2,
          TwentyFourMthPetType_2,
          TwentyFourMthRenovateRoom_2,
          TwentyFourMthRoomMold_2,
          VacuumBag,
          VacuumBagOutside,
          VacuumBag_2,
          VacuumBagOutside_2,
          VacuumBagSaq,
          VacuumBagSaqOutside,
          VacuumBagSaqProb,
          ValidationIns
      end
    end
  end
end

::DataMapper.finalize
