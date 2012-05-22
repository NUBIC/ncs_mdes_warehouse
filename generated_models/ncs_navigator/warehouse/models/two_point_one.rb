module NcsNavigator
  module Warehouse
    module Models
      module TwoPointOne
        extend NcsNavigator::Warehouse::Models::MdesModelCollection
      end
    end
  end
end

require 'ncs_navigator/warehouse/models/two_point_one/study_center'
require 'ncs_navigator/warehouse/models/two_point_one/psu'
require 'ncs_navigator/warehouse/models/two_point_one/ssu'
require 'ncs_navigator/warehouse/models/two_point_one/tsu'
require 'ncs_navigator/warehouse/models/two_point_one/listing_unit'
require 'ncs_navigator/warehouse/models/two_point_one/dwelling_unit'
require 'ncs_navigator/warehouse/models/two_point_one/household_unit'
require 'ncs_navigator/warehouse/models/two_point_one/link_household_dwelling'
require 'ncs_navigator/warehouse/models/two_point_one/staff'
require 'ncs_navigator/warehouse/models/two_point_one/staff_language'
require 'ncs_navigator/warehouse/models/two_point_one/staff_validation'
require 'ncs_navigator/warehouse/models/two_point_one/staff_weekly_expense'
require 'ncs_navigator/warehouse/models/two_point_one/staff_exp_mngmnt_tasks'
require 'ncs_navigator/warehouse/models/two_point_one/staff_exp_data_cllctn_tasks'
require 'ncs_navigator/warehouse/models/two_point_one/outreach'
require 'ncs_navigator/warehouse/models/two_point_one/outreach_race'
require 'ncs_navigator/warehouse/models/two_point_one/outreach_staff'
require 'ncs_navigator/warehouse/models/two_point_one/outreach_eval'
require 'ncs_navigator/warehouse/models/two_point_one/outreach_target'
require 'ncs_navigator/warehouse/models/two_point_one/outreach_lang2'
require 'ncs_navigator/warehouse/models/two_point_one/staff_cert_training'
require 'ncs_navigator/warehouse/models/two_point_one/person'
require 'ncs_navigator/warehouse/models/two_point_one/person_race'
require 'ncs_navigator/warehouse/models/two_point_one/link_person_household'
require 'ncs_navigator/warehouse/models/two_point_one/participant'
require 'ncs_navigator/warehouse/models/two_point_one/link_person_participant'
require 'ncs_navigator/warehouse/models/two_point_one/participant_auth'
require 'ncs_navigator/warehouse/models/two_point_one/participant_consent'
require 'ncs_navigator/warehouse/models/two_point_one/ppg_details'
require 'ncs_navigator/warehouse/models/two_point_one/ppg_status_history'
require 'ncs_navigator/warehouse/models/two_point_one/provider'
require 'ncs_navigator/warehouse/models/two_point_one/provider_role'
require 'ncs_navigator/warehouse/models/two_point_one/link_person_provider'
require 'ncs_navigator/warehouse/models/two_point_one/institution'
require 'ncs_navigator/warehouse/models/two_point_one/link_person_institute'
require 'ncs_navigator/warehouse/models/two_point_one/address'
require 'ncs_navigator/warehouse/models/two_point_one/telephone'
require 'ncs_navigator/warehouse/models/two_point_one/email'
require 'ncs_navigator/warehouse/models/two_point_one/event'
require 'ncs_navigator/warehouse/models/two_point_one/instrument'
require 'ncs_navigator/warehouse/models/two_point_one/contact'
require 'ncs_navigator/warehouse/models/two_point_one/link_contact'
require 'ncs_navigator/warehouse/models/two_point_one/non_interview_rpt'
require 'ncs_navigator/warehouse/models/two_point_one/non_interview_rpt_vacant'
require 'ncs_navigator/warehouse/models/two_point_one/non_interview_rpt_noaccess'
require 'ncs_navigator/warehouse/models/two_point_one/non_interview_rpt_refusal'
require 'ncs_navigator/warehouse/models/two_point_one/non_interview_rpt_dutype'
require 'ncs_navigator/warehouse/models/two_point_one/incident'
require 'ncs_navigator/warehouse/models/two_point_one/incident_media'
require 'ncs_navigator/warehouse/models/two_point_one/incident_unanticipated'
require 'ncs_navigator/warehouse/models/two_point_one/spec_equipment'
require 'ncs_navigator/warehouse/models/two_point_one/spec_pickup'
require 'ncs_navigator/warehouse/models/two_point_one/spec_receipt'
require 'ncs_navigator/warehouse/models/two_point_one/spec_shipping'
require 'ncs_navigator/warehouse/models/two_point_one/spec_storage'
require 'ncs_navigator/warehouse/models/two_point_one/spec_spsc_info'
require 'ncs_navigator/warehouse/models/two_point_one/env_equipment'
require 'ncs_navigator/warehouse/models/two_point_one/env_equipment_prob_log'
require 'ncs_navigator/warehouse/models/two_point_one/participant_consent_sample'
require 'ncs_navigator/warehouse/models/two_point_one/participant_rvis'
require 'ncs_navigator/warehouse/models/two_point_one/participant_vis_consent'
require 'ncs_navigator/warehouse/models/two_point_one/prec_therm_cert'
require 'ncs_navigator/warehouse/models/two_point_one/ref_freezer_verification'
require 'ncs_navigator/warehouse/models/two_point_one/sample_receipt_store'
require 'ncs_navigator/warehouse/models/two_point_one/sample_shipping'
require 'ncs_navigator/warehouse/models/two_point_one/srsc_info'
require 'ncs_navigator/warehouse/models/two_point_one/subsample_doc'
require 'ncs_navigator/warehouse/models/two_point_one/trh_meter_calibration'
require 'ncs_navigator/warehouse/models/two_point_one/drf_therm_verification'
require 'ncs_navigator/warehouse/models/two_point_one/sample_receipt_confirm'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_baby_name'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_decorate_room'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_renovate_room'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_2'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_baby_name_2'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_decorate_room_2'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_renovate_room_2'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_li'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_li_baby_name'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_li_decorate_room'
require 'ncs_navigator/warehouse/models/two_point_one/birth_visit_li_renovate_room'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_cond'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_detail'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_habits'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_lice'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_mold'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_pet_type'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_renovate_room'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_room_mold'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_prescr'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_otc'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_suppl'
require 'ncs_navigator/warehouse/models/two_point_one/eighteen_mth_mother_saq'
require 'ncs_navigator/warehouse/models/two_point_one/father_pv1'
require 'ncs_navigator/warehouse/models/two_point_one/father_pv1_cancer'
require 'ncs_navigator/warehouse/models/two_point_one/father_pv1_educ'
require 'ncs_navigator/warehouse/models/two_point_one/father_pv1_race'
require 'ncs_navigator/warehouse/models/two_point_one/father_pv1_2'
require 'ncs_navigator/warehouse/models/two_point_one/father_pv1_cancer_2'
require 'ncs_navigator/warehouse/models/two_point_one/father_pv1_race_2'
require 'ncs_navigator/warehouse/models/two_point_one/household_enumeration'
require 'ncs_navigator/warehouse/models/two_point_one/household_enumeration_age_elig'
require 'ncs_navigator/warehouse/models/two_point_one/household_enumeration_hidden_du'
require 'ncs_navigator/warehouse/models/two_point_one/household_enumeration_pregnant'
require 'ncs_navigator/warehouse/models/two_point_one/household_inventory'
require 'ncs_navigator/warehouse/models/two_point_one/household_inventory_age'
require 'ncs_navigator/warehouse/models/two_point_one/household_inventory_age_elig'
require 'ncs_navigator/warehouse/models/two_point_one/internet_usage'
require 'ncs_navigator/warehouse/models/two_point_one/internet_usage_participate'
require 'ncs_navigator/warehouse/models/two_point_one/low_high_script'
require 'ncs_navigator/warehouse/models/two_point_one/nine_mth_mother'
require 'ncs_navigator/warehouse/models/two_point_one/nine_mth_mother_detail'
require 'ncs_navigator/warehouse/models/two_point_one/pb_recruitment'
require 'ncs_navigator/warehouse/models/two_point_one/pb_recruitment_info_source'
require 'ncs_navigator/warehouse/models/two_point_one/pb_recruitment_prov_source'
require 'ncs_navigator/warehouse/models/two_point_one/pb_recruitment_prov_svc'
require 'ncs_navigator/warehouse/models/two_point_one/pb_recruitment_2'
require 'ncs_navigator/warehouse/models/two_point_one/pb_recruitment_info_source_2'
require 'ncs_navigator/warehouse/models/two_point_one/pb_recruitment_prov_source_2'
require 'ncs_navigator/warehouse/models/two_point_one/pb_recruitment_prov_svc_2'
require 'ncs_navigator/warehouse/models/two_point_one/ppg_cati'
require 'ncs_navigator/warehouse/models/two_point_one/ppg_saq'
require 'ncs_navigator/warehouse/models/two_point_one/pre_preg'
require 'ncs_navigator/warehouse/models/two_point_one/pre_preg_cool'
require 'ncs_navigator/warehouse/models/two_point_one/pre_preg_heat2'
require 'ncs_navigator/warehouse/models/two_point_one/pre_preg_pdecorate_room'
require 'ncs_navigator/warehouse/models/two_point_one/pre_preg_prenovate_room'
require 'ncs_navigator/warehouse/models/two_point_one/pre_preg_room_mold'
require 'ncs_navigator/warehouse/models/two_point_one/pre_preg_sp_race'
require 'ncs_navigator/warehouse/models/two_point_one/pre_preg_saq'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_eh'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_eh_know_ncs'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_eh_race'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_eh_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_eh_know_ncs_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_eh_race_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_hi'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_hi_know_ncs'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_hi_race'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_hi_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_hi_know_ncs_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_hi_race_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_pb'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_pb_know_ncs'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_pb_race'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_pb_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_pb_know_ncs_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_screen_pb_race_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_commute'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_cool'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_diagnose_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_heat2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_local_trav'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_pdecorate_room'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_pet_type'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_prenovate_room'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_prenovate2_room'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_room_mold'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_sp_race'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_commute_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_cool_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_diagnose_2_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_heat2_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_local_trav_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_nonenglish2_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_pdecorate_room_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_pet_type_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_prenovate_room_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_room_mold_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_sp_race_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_saq'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_saq_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_1_saq_3'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_cool'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_diagnose_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_heat2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_pdecorate2_room'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_prenovate_room'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_room_mold'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_cool_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_diagnose_2_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_heat2_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_pdecorate2_room_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_prenovate_room_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_room_mold_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_saq'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_2_saq_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_li'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_li_cool'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_li_2'
require 'ncs_navigator/warehouse/models/two_point_one/preg_visit_li_cool_2'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_mother'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_mother_detail'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_mother_pet'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_saq'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_saq_formula_type'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_saq_supp'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_saq_water'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_saq_2'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_saq_formula_type_2'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_saq_supp_2'
require 'ncs_navigator/warehouse/models/two_point_one/six_mth_saq_water_2'
require 'ncs_navigator/warehouse/models/two_point_one/spec_blood'
require 'ncs_navigator/warehouse/models/two_point_one/spec_blood_draw'
require 'ncs_navigator/warehouse/models/two_point_one/spec_blood_hemolyze'
require 'ncs_navigator/warehouse/models/two_point_one/spec_blood_tube_comments'
require 'ncs_navigator/warehouse/models/two_point_one/spec_blood_tube'
require 'ncs_navigator/warehouse/models/two_point_one/spec_cord_blood'
require 'ncs_navigator/warehouse/models/two_point_one/spec_cord_blood_specimen'
require 'ncs_navigator/warehouse/models/two_point_one/spec_cord_blood_2'
require 'ncs_navigator/warehouse/models/two_point_one/spec_cord_blood_specimen_2'
require 'ncs_navigator/warehouse/models/two_point_one/spec_urine'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf_blank_collected'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf_dup_collected'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf_dup_filled'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf_n_collected'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf_reason_filled'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf_reason_filled2'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf_sample'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twf_subsamples'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq_blank_collected'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq_dup_collected'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq_dup_filled'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq_n_collected'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq_reason_filled'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq_reason_filled2'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq_sample'
require 'ncs_navigator/warehouse/models/two_point_one/tap_water_twq_subsamples'
require 'ncs_navigator/warehouse/models/two_point_one/three_mth_mother'
require 'ncs_navigator/warehouse/models/two_point_one/three_mth_mother_child_detail'
require 'ncs_navigator/warehouse/models/two_point_one/three_mth_mother_child_habits'
require 'ncs_navigator/warehouse/models/two_point_one/three_mth_mother_race'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_mother'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_mother_detail'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_mother_lice'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_mother_renovate_room'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_mother_room_mold'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_formula_brand'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_formula_type'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_supplement'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_water'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_2'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_formula_brand_2'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_formula_type_2'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_supplement_2'
require 'ncs_navigator/warehouse/models/two_point_one/twelve_mth_saq_water_2'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_mother'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_mother_cond'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_mother_detail'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_mother_habits'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_mother_mold'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_pet_type'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_renovate_room'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_room_mold'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_mother_prescr'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_mother_otc'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_mother_suppl'
require 'ncs_navigator/warehouse/models/two_point_one/twenty_four_mth_saq'
require 'ncs_navigator/warehouse/models/two_point_one/vacuum_bag'
require 'ncs_navigator/warehouse/models/two_point_one/vacuum_bag_outside'
require 'ncs_navigator/warehouse/models/two_point_one/validation_ins'

module NcsNavigator
  module Warehouse
    module Models
      module TwoPointOne
        mdes_version "2.1"
        mdes_specification_version "2.1.00.00"
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
          BirthVisit,
          BirthVisitBabyName,
          BirthVisitDecorateRoom,
          BirthVisitRenovateRoom,
          BirthVisit_2,
          BirthVisitBabyName_2,
          BirthVisitDecorateRoom_2,
          BirthVisitRenovateRoom_2,
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
          NineMthMother,
          NineMthMotherDetail,
          PbRecruitment,
          PbRecruitmentInfoSource,
          PbRecruitmentProvSource,
          PbRecruitmentProvSvc,
          PbRecruitment_2,
          PbRecruitmentInfoSource_2,
          PbRecruitmentProvSource_2,
          PbRecruitmentProvSvc_2,
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
          PregVisit1Saq,
          PregVisit1Saq_2,
          PregVisit1Saq_3,
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
          PregVisit2Saq,
          PregVisit2Saq_2,
          PregVisitLi,
          PregVisitLiCool,
          PregVisitLi_2,
          PregVisitLiCool_2,
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
          SpecBlood,
          SpecBloodDraw,
          SpecBloodHemolyze,
          SpecBloodTubeComments,
          SpecBloodTube,
          SpecCordBlood,
          SpecCordBloodSpecimen,
          SpecCordBlood_2,
          SpecCordBloodSpecimen_2,
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
          TapWaterTwq,
          TapWaterTwqBlankCollected,
          TapWaterTwqDupCollected,
          TapWaterTwqDupFilled,
          TapWaterTwqNCollected,
          TapWaterTwqReasonFilled,
          TapWaterTwqReasonFilled2,
          TapWaterTwqSample,
          TapWaterTwqSubsamples,
          ThreeMthMother,
          ThreeMthMotherChildDetail,
          ThreeMthMotherChildHabits,
          ThreeMthMotherRace,
          TwelveMthMother,
          TwelveMthMotherDetail,
          TwelveMthMotherLice,
          TwelveMthMotherRenovateRoom,
          TwelveMthMotherRoomMold,
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
          VacuumBag,
          VacuumBagOutside,
          ValidationIns
      end
    end
  end
end

::DataMapper.finalize
