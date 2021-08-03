# frozen_string_literal: true

require "decidim/civicrm/api"

GROUPS = {
  alt_pirineu: {
    inscrites: {
      id: 12,
      name: "Alt_Pirineu_Aran_12",
      title: "Inscrites de l'Alt Pirineu i Aran",
      ref: "AT-I-APA"
    },
    executiva: {
      id: 142,
      name: "Executiva_Alt_Pirineu_i_Aran_142",
      title: "Executiva de l'Alt Pirineu i Aran",
      ref: "AT-E-APA"
    }
  },
  baix_llobregat: {
    inscrites: {
      id: 14,
      name: "Baix_Llobregat_14",
      title: "Inscrites del Baix Llobregat",
      ref: "AT-I-BL"
    },
    executiva: {
      id: 138,
      name: "Executiva_Baix_Llobregat_138",
      title: "Executiva del Baix Llobregat",
      ref: "AT-E-BL"
    }
  },
  barcelones: {
    inscrites: {
      id: 15,
      name: "Barcelon_s_15",
      title: "Inscrites del Barcelonès",
      ref: "AT-I-B"
    },
    executiva: {
      id: 146,
      name: "Executiva_Barcelon_s_146",
      title: "Executiva del Barcelonès",
      ref: "AT-E-B"
    }
  },
  camp_de_tarragona: {
    inscrites: {
      id: 16,
      name: "Camp_de_Tarragona_16",
      title: "Inscrites del Camp de Tarragona",
      ref: "AT-I-CT"
    },
    executiva: {
      id: 147,
      name: "Executiva_Camp_de_Tarragona_147",
      title: "Executiva del Camp de Tarragona",
      ref: "AT-E-CT"
    }
  },
  catalunya_central: {
    inscrites: {
      id: 17,
      name: "Comarques_Centrals_17",
      title: "Inscrites de les Comarques Centrals",
      ref: "AT-I-CC"
    },
    executiva: {
      id: 139,
      name: "Executiva_Catalunya_Central_139",
      title: "Executiva de les Comarques Centrals",
      ref: "AT-E-CC"
    }
  },
  comarques_gironines: {
    inscrites: {
      id: 18,
      name: "Comarques_Gironines_18",
      title: "Inscrites de les Comarques Gironines",
      ref: "AT-I-CG"
    },
    executiva: {
      id: 145,
      name: "Executiva_Comarques_Gironines_145",
      title: "Executiva de les Comarques Gironines",
      ref: "AT-E-CG"
    }
  },
  maresme: {
    inscrites: {
      id: 19,
      name: "Maresme_19",
      title: "Inscrites del Maresme",
      ref: "AT-I-M"
    },
    executiva: {
      id: 149,
      name: "Executiva_Maresme_149",
      title: "Executiva del Maresme",
      ref: "AT-E-M"
    }
  },
  penedes: {
    inscrites: {
      id: 20,
      name: "Pened_s_20",
      title: "Inscrites del Penedès",
      ref: "AT-I-P"
    },
    executiva: {
      id: 144,
      name: "Executiva_Pened_s_144",
      title: "Executiva del Penedès",
      ref: "AT-E-P"
    }
  },
  ponent: {
    inscrites: {
      id: 21,
      name: "Ponent_21",
      title: "Inscrites de les Terres de Ponent",
      ref: "AT-I-L"
    },
    executiva: {
      id: 143,
      name: "Executiva_Terres_de_Lleida_143",
      title: "Executiva de les Terres de Ponent",
      ref: "AT-E-L"
    }
  },
  terres_de_lebre: {
    inscrites: {
      id: 22,
      name: "Terres_de_l_Ebre_22",
      title: "Inscrites de les Terres de l'Ebre",
      ref: "AT-I-E"
    },
    executiva: {
      id: 148,
      name: "Executiva_Terres_de_l_Ebre_148",
      title: "Executiva de les Terres de l'Ebre",
      ref: "AT-E-E"
    }
  },
  valles_occidental: {
    inscrites: {
      id: 23,
      name: "Vall_s_Occidental_23",
      title: "Inscrites del Vallès Occidental",
      ref: "AT-I-VOC"
    },
    executiva: {
      id: 140,
      name: "Executiva_Vall_s_Occidental_140",
      title: "Executiva del Vallès Occidental",
      ref: "AT-E-VOC"
    }
  },
  valles_oriental: {
    inscrites: {
      id: 24,
      name: "Vall_s_Oriental_24",
      title: "Inscrites del Vallès Oriental",
      ref: "AT-I-VOR"
    },
    executiva: {
      id: 141,
      name: "Executiva_Vall_s_Oriental_141",
      title: "Executiva del Vallès Oriental",
      ref: "AT-E-VOR"
    }
  }
}.freeze

namespace :civicrm do
  # invoke with 'bundle exec rake "civicrm:create_private_process_for_group[1]"'

  desc "Create private participatory processes for Civicrm Groups"
  task :create_private_process_for_groups, [:organization_id] => :environment do |_t, args|
    organization = Decidim::Organization.find(args[:organization_id])
    participatory_process_group = Decidim::ParticipatoryProcessGroup.find_by(organization: organization)

    GROUPS.each do |key, group|
      [:inscrites, :executiva].each do |group_type|
        translated_title = I18n.available_locales.map { |locale| [locale, group[group_type][:title]] }.to_h
        private_process = Decidim::ParticipatoryProcess.create!(
          organization: organization,
          slug: "#{group_type}-#{key}".gsub("_", "-"),
          title: translated_title,
          subtitle: translated_title,
          short_description: translated_title,
          description: translated_title,
          participatory_process_group: participatory_process_group,
          scopes_enabled: false,
          private_space: true,
          reference: group[group_type][:reference]
        )

        Decidim::Civicrm::ParticipatoryProcessGroupAssignment.create!(
          organization: organization,
          participatory_process: private_process,
          civicrm_group_id: group[:inscrites][:id]
        )
      end
    end
  end

  desc "Update private process participants from assigned civirm groups"
  task :update_private_participants, [:organization_id] => :environment do |_t, args|
    UpdateCivicrmGroupsJob.perform_later(args[:organization_id])
  end
end
