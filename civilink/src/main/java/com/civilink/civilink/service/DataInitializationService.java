package com.civilink.civilink.service;

import com.civilink.civilink.entity.Commune;
import com.civilink.civilink.entity.Institution;
import com.civilink.civilink.entity.Quartier;
import com.civilink.civilink.repository.CommuneRepository;
import com.civilink.civilink.repository.InstitutionRepository;
import com.civilink.civilink.repository.QuartierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.util.Arrays;
import java.util.List;

@Service
public class DataInitializationService {

    @Autowired
    private CommuneRepository communeRepository;

    @Autowired
    private QuartierRepository quartierRepository;

    @Autowired
    private InstitutionRepository institutionRepository;

    @PostConstruct
    public void initData() {
        if (communeRepository.count() == 0) {
            initializeCommunesAndQuartiers();
        }
    }

    private void initializeCommunesAndQuartiers() {
        // Communes Golfe
        Commune golfe1 = new Commune("Golfe 1", "Golfe");
        communeRepository.save(golfe1);
        createQuartiersForCommune(golfe1, Arrays.asList("Baguida", "Kpogan", "Bè-Est"));
        createInstitutionsForCommune(golfe1);

        Commune golfe2 = new Commune("Golfe 2", "Golfe");
        communeRepository.save(golfe2);
        createQuartiersForCommune(golfe2, Arrays.asList("Tokoin Wuiti", "Tokoin Tamé", "Tokoin Enyonam", "Hédzranawoé (1 et 2)", "Tokoin Aviation", "Kégué", "Atiégouvi"));
        createInstitutionsForCommune(golfe2);

        Commune golfe3 = new Commune("Golfe 3", "Golfe");
        communeRepository.save(golfe3);
        createQuartiersForCommune(golfe3, Arrays.asList("Tokoin Elavagnon", "Gbonvié", "Doumasséssé (Adewi)", "Cité OUA", "Lomé II", "Kélégouvi", "Hanoukopé"));
        createInstitutionsForCommune(golfe3);

        Commune golfe4 = new Commune("Golfe 4", "Golfe");
        communeRepository.save(golfe4);
        createQuartiersForCommune(golfe4, Arrays.asList("Dékon", "Hanoukopé", "Bassadji", "N'tifafa-komé", "Aguiakomé", "Assivito", "Kodjoviakopé"));
        createInstitutionsForCommune(golfe4);

        Commune golfe5 = new Commune("Golfe 5", "Golfe");
        communeRepository.save(golfe5);
        createQuartiersForCommune(golfe5, Arrays.asList("Adidogomé", "Sagbado"));
        createInstitutionsForCommune(golfe5);

        Commune golfe6 = new Commune("Golfe 6", "Golfe");
        communeRepository.save(golfe6);
        createQuartiersForCommune(golfe6, Arrays.asList("Baguida", "Togblekopé"));
        createInstitutionsForCommune(golfe6);

        Commune golfe7 = new Commune("Golfe 7", "Golfe");
        communeRepository.save(golfe7);
        createQuartiersForCommune(golfe7, Arrays.asList("Baguida", "Togblekopé"));
        createInstitutionsForCommune(golfe7);

        // Communes Agoè-Nyivé
        Commune agoenyive1 = new Commune("Agoè-Nyivé 1", "Agoè-Nyivé");
        communeRepository.save(agoenyive1);
        createQuartiersForCommune(agoenyive1, Arrays.asList("Agoè-nyivé", "Agbalépédogan", "Attikoumè", "Avédji"));
        createInstitutionsForCommune(agoenyive1);

        Commune agoenyive5 = new Commune("Agoè-Nyivé 5", "Agoè-Nyivé");
        communeRepository.save(agoenyive5);
        createQuartiersForCommune(agoenyive5, Arrays.asList("Sanguéra", "Klikamé", "Kohé", "Togblékopé", "Zossimé", "Dékpor", "Afiadényigban"));
        createInstitutionsForCommune(agoenyive5);

        // Autres communes
        Commune adetikope = new Commune("Adétikopé", "Agoè-Nyivé");
        communeRepository.save(adetikope);
        createQuartiersForCommune(adetikope, Arrays.asList("Adétikopé"));
        createInstitutionsForCommune(adetikope);

        Commune vakpossito = new Commune("Vakpossito", "Agoè-Nyivé");
        communeRepository.save(vakpossito);
        createQuartiersForCommune(vakpossito, Arrays.asList("Vakpossito"));
        createInstitutionsForCommune(vakpossito);

        Commune legbassito = new Commune("Légbassito", "Agoè-Nyivé");
        communeRepository.save(legbassito);
        createQuartiersForCommune(legbassito, Arrays.asList("Légbassito"));
        createInstitutionsForCommune(legbassito);
    }

    private void createQuartiersForCommune(Commune commune, List<String> quartierNames) {
        for (String name : quartierNames) {
            Quartier quartier = new Quartier(name, commune);
            quartierRepository.save(quartier);
        }
    }

    private void createInstitutionsForCommune(Commune commune) {
        // Mairie
        Institution mairie = new Institution("mairie", "Mairie de " + commune.getName(), commune);
        institutionRepository.save(mairie);

        // Gendarmerie
        Institution gendarmerie = new Institution("gendarmerie", "Gendarmerie de " + commune.getName(), commune);
        institutionRepository.save(gendarmerie);

        // Hôpital public
        Institution hopitalPublic = new Institution("hopital_public", "Hôpital public de " + commune.getName(), commune);
        institutionRepository.save(hopitalPublic);

        // CMS
        Institution cms = new Institution("cms", "CMS de " + commune.getName(), commune);
        institutionRepository.save(cms);

        // Clinique
        Institution clinique = new Institution("clinique", "Clinique de " + commune.getName(), commune);
        institutionRepository.save(clinique);

        // Pompiers
        Institution pompiers = new Institution("pompiers", "Caserne de pompiers de " + commune.getName(), commune);
        institutionRepository.save(pompiers);

        // Voirie
        Institution voirie = new Institution("voirie", "Service de voirie de " + commune.getName(), commune);
        institutionRepository.save(voirie);

        // Police (optionnel, mais mentionné dans les accidents)
        Institution police = new Institution("police", "Police de " + commune.getName(), commune);
        institutionRepository.save(police);
    }
}
