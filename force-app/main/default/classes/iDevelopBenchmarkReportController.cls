/**
* Controller for iDevelopBenchmarkReport PDF for generating data for the iDevelop Report Out PDF
* @author Ethan Hirsch @ Zoetis Inc
* @since 03-02-2023
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   03-02-2023   Ethan Hirsch @ Zoetis Inc   Initial Version with Manager ratings only
* 1.1   03-31-2023   Ethan Hirsch @ Zoetis Inc   Add support for Self Ratings including calculating highest/lowest gaps
* 1.2   04-10-2023   Ethan Hirsch @ Zoetis Inc   Add retrieveCompetencyModelTranslations method to translate
*                                                Competency Model Names on the PDF
* 1.3   05-23-2023   Padma Nerella @ Zoetis Inc  Remaned selectByObservedCompetencyCompetency method to selectByObservedCompetencyCompetencyAndBenchmark 
*                                                method and add set of BenchamrkId as a parameter in lessonsSelector class to avoid duplicate lesson TPDEV-1172
* 1.4   06-26-2023   Sai Saranya  @Deloitte      Added retrieveComments() to show comments in the pdf as part of TPDEV-1213.
* 1.5   10-16-2023   Neeraj Rautela @Deloitte    Added recent past benchmark scores in the pdf under Scoring Category Summary. 
*/
public with sharing class iDevelopBenchmarkReportController {
    public List<CompetencyModelScore> BenchmarkScores {get; private set;}
    public List<ObservationComments> CoachObservations {get; private set;}
    public String CoacheeName {get; private set;}
    public String RaterName {get; private set;}
    public String CurrentDate {get; private set;}
    public Id BenchmarkId {get; private set;}
    private static final Integer maxScoresPerRanking = 3;
    public List<HighestLowestScore> HighestScores {get; private set;}
    public List<HighestLowestScore> LowestScores {get; private set;}
    public List<HighestLowestGap> TopPositiveGaps {get; private set;}
    public List<HighestLowestGap> TopNegativeGaps {get; private set;}
    public List<CompetencyRecommendedELearnings> LowestScoringCompetencies {get; private set;}
    public String Title {get; private set;}
    public transient String PdfFile {get; set;}
    public String SalesforceBaseUrl {get; private set;}
    public Boolean SelfObservationPresent {get; private set;}
    public Boolean PreviousSelfObservationPresent {get; private set;} //neeraj
    public Boolean PreviousObservationPresent {get; private set;} //neeraj
    Public Boolean commentsAvailable{ get; private set;}
    public String UserLanguage {get; set;}
    /**
* Constructor that pulls back all data needed for the Page
*/
    public iDevelopBenchmarkReportController(ApexPages.StandardController controller) {
        String benchmarkId = controller.getId();
        doInitialSetup(benchmarkId);
    }
    
    /** TPDEV 1205 - Constructor to get the previous BenchmarkReport Data **/
    public iDevelopBenchmarkReportController(String benchmarkId) {
        doInitialSetup(benchmarkId, false);
        
        /* Calculate Average Score */
        if(BenchmarkScores != null){
            for (CompetencyModelScore benchmarkScore : BenchmarkScores) {
                for (CompetencySkillAverageScore competencySkilLAverageScore :
                     benchmarkScore.CompetencySkillAverageScores) {
                         competencySkilLAverageScore.calculateAverageScores();
                         for (CompetencySkillAverageScore skillAverageScore :
                              competencySkilLAverageScore.SkillScores) {
                                  skillAverageScore.calculateAverageScores();
                              }
                     }
            }
        }
    }
    
    public void doInitialSetup(String benchmarkId){
        doInitialSetup(benchmarkId, true);
    }
    
    public void doInitialSetup(String benchmarkId, Boolean retrievePreviousBenchMark){
        // Initialize collections that will be populated later
        this.HighestScores = new List<HighestLowestScore>();
        this.LowestScores = new List<HighestLowestScore>();
        this.TopPositiveGaps = new List<HighestLowestGap>();
        this.TopNegativeGaps = new List<HighestLowestGap>();
        this.LowestScoringCompetencies = new List<CompetencyRecommendedELearnings>();
        this.SalesforceBaseUrl = Url.getSalesforceBaseUrl().toExternalForm();
        this.SelfObservationPresent = false;
        this.PreviousSelfObservationPresent = false; // Added variable as part of TPDEV-1205
        this.PreviousObservationPresent = false; //// Added variable as part of TPDEV-1205
        this.CoachObservations = new List<ObservationComments>();
        
        Map<Id, Observation__c> observationMap = new Map<Id, Observation__c>();
        
        //CurrentDate = System.now().format('MMMM dd, yyyy');
        CurrentDate = System.now().format('dd/MM/yyyy');
        
        this.BenchmarkId = benchmarkId;
        
        Set<Id> benchmarkIds = new Set<Id>();
        benchmarkIds.add(BenchmarkId);
        
        String coacheeLocale;
        Benchmark__c selectPreviousBenchmark;
        // Only 1 Benchmark will be returned, but a for loop is used to save on memory and just in case
        for (Benchmark__c benchmark : BenchmarksSelector.selectByIdWithObservations(benchmarkIds)){
            CoacheeName = benchmark.Coachee__r.Name;	
            RaterName = benchmark.Owner.Name;
            coacheeLocale = benchmark.Coachee__r.LanguageLocaleKey;
            observationMap = new Map<Id, Observation__c>(benchmark.Observations__r);
            //TPDEV-1205 - If benchmark type is 'Coach' then fetch fetch previous benchmark of the coachee
            if(retrievePreviousBenchMark == true){
                if(benchmark.Type__c == 'Coach'){
                    selectPreviousBenchmark = BenchmarksSelector.selectPreviousBenchmark(benchmark.Id, benchmark.Coachee__c, benchmark.CreatedDate);
                }
            }
            
            if(retrievePreviousBenchMark == true){
                Title = String.format('{0}{1}',
                                      new List<String>{coacheeName, System.Label.iDevelop_Benchmark_Report_File_Name_Suffix});
            }
        }
        
        this.UserLanguage = coacheeLocale;
        
        List<Observed_Competency__c> observedCompetencies = ObservedCompetenciesSelector.selectByObservations(
            observationMap.keySet());
        
        Map<Id, String> competencyModelTranslationsById = retrieveCompetencyModelTranslations(observedCompetencies,
                                                                                              coacheeLocale);
        
        List<Observation__c> lstobservations = ObservationSelector.selectByBenchmarkId(benchmarkIds);
        
        setupBenchmarkScores(observedCompetencies, competencyModelTranslationsById);
        if(retrievePreviousBenchMark == true){
            calculateAveragesHighestLowestScoresAndGaps();
            
            setupELearnings();
            retrieveComments(lstobservations); 
            
            //TPDEV-1205 Calculate Previous BenchmarkScores
            calculatePreviousScore(selectPreviousBenchmark?.Id);
        }
    }
    
    public void calculatePreviousScore(String previousBenchmarkId){
        if(String.isNotBlank(previousBenchmarkId)){
            this.PreviousObservationPresent = true;
            iDevelopBenchmarkReportController controllerInstance = new iDevelopBenchmarkReportController(previousBenchmarkId);
            this.PreviousSelfObservationPresent = controllerInstance.SelfObservationPresent;
            List<CompetencyModelScore> PreviousBenchmarkScores = controllerInstance.BenchmarkScores;
            Map<String, CompetencyModelScore> previousBenchmarkScoresMap = new Map<String, CompetencyModelScore>();
            if(PreviousBenchmarkScores != null){
                for(CompetencyModelScore PreviousBenchmarkScore :PreviousBenchmarkScores){
                    previousBenchmarkScoresMap.put(PreviousBenchmarkScore.Name, PreviousBenchmarkScore);
                }
            }
            if(this.BenchmarkScores != null){
                for(CompetencyModelScore benchmarkScore :BenchmarkScores){
                    if(previousBenchmarkScoresMap.containsKey(benchmarkScore.Name)){
                        CompetencyModelScore previousBenchmarkScore = previousBenchmarkScoresMap.get(benchmarkScore.Name);
                        Map<String, CompetencySkillAverageScore> previousCompetencySkilLAverageScoreMap = new Map<String, CompetencySkillAverageScore>();
                        for(CompetencySkillAverageScore competencySkilLAverageScore : previousBenchmarkScore.CompetencySkillAverageScores){
                            previousCompetencySkilLAverageScoreMap.put(competencySkilLAverageScore.Name, competencySkilLAverageScore);
                        }
                        for (CompetencySkillAverageScore competencySkilLAverageScore : benchmarkScore.CompetencySkillAverageScores) {
                            if(previousCompetencySkilLAverageScoreMap.containsKey(competencySkilLAverageScore.Name)){
                                CompetencySkillAverageScore previousCompetencySkilLAverageScore = previousCompetencySkilLAverageScoreMap.get(competencySkilLAverageScore.Name); 
                                competencySkilLAverageScore.PreviousManagerAverageScore = previousCompetencySkilLAverageScore.ManagerAverageScore;
                                competencySkilLAverageScore.PreviousSelfAverageScore = previousCompetencySkilLAverageScore.SelfAverageScore;
                            } 
                        }
                    }
                }
            }
        }
    }
    
    /**
    
* Save the PDF to the Benchmark.
*/
    public void savePDF() {
        String fileName = String.format('{0}.pdf', new List<String>{Title});
        
        ContentVersion file = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = EncodingUtil.base64Decode(PdfFile),
            origin = 'H'
        );
        
        // If a file already exists with the same name generate a new version of the file
        List<ContentDocumentLink> existingContentDocumentLinks = ContentDocumentLinksSelector.selectByTitlesAndLinkedEntityId(
            new Set<String> {fileName}, new Set<Id> {BenchmarkId}
        );
        
        if (!existingContentDocumentLinks.isEmpty()) {
            file.ContentDocumentId = existingContentDocumentLinks[0].ContentDocumentId;
        }
        
        // Run inserts WithoutSharing to update files owned by other Users
        WithoutSharing withoutSharing = new WithoutSharing();
        withoutSharing.insertRecords(new List<SObject> {file});
        
        if (existingContentDocumentLinks.isEmpty()) {
            withoutSharing.insertRecords(new List<SObject> {new ContentDocumentLink(
                LinkedEntityId = BenchmarkId,
                ContentDocumentId = ContentVersionsSelector.selectById(new Set<Id> {file.Id})[0].ContentDocumentId
            ) });
        }
    }
    
    /**
* Retrieves the Observation records for the Benchmark.
* @param observations  
*/
    Private void retrieveComments(List<Observation__c> listObservation) {
        List<Observation__c> tempList = new List<Observation__c>();
        commentsAvailable = false;
        for(Observation__c obs: listObservation){
            if(obs.Type__c == 'Coach' && !String.isBlank(obs.Comments__c)){
                commentsAvailable=true;
                CoachObservations.add(new ObservationComments(obs));
            }
        }
    }
    
    /**
* Retrieves the Data Translation records for the Coachee's Locale and the related Competency Models.
* @param observedCompetencies 
* @param coacheeLocale 
* @return  `Map<Id, String>`
*/
    private Map<Id, String> retrieveCompetencyModelTranslations(List<Observed_Competency__c> observedCompetencies, String coacheeLocale) {
        Set<Id> competencyModelIds = new Set<Id>();
        for (Observed_Competency__c observedCompetency : observedCompetencies) {
            competencyModelIds.add(observedCompetency.Competency__r?.Competency_Model__c);
        }
        
        Map<Id, String> translatedModelNameById = new Map<Id, String>();
        for (Data_Translation__c translation : DataTranslationsSelector.selectDataTransByCompetencyModelIdsAndLocales(
            competencyModelIds, new Set<String> {coacheeLocale})) {
                translatedModelNameById.put(translation.Competency_Model__c, translation.Name);
            }
        
        return translatedModelNameById;
    }
    
    /**
* Create CompetencyModelScore objects and place it into the BenchmarkScore properties
* The report charts will be based off this data 
* @param observedCompetencies 
* @param competencyModelTranslationsById
*/
    private void setupBenchmarkScores(List<Observed_Competency__c> observedCompetencies, Map<Id, String> competencyModelTranslationsById) {
        Map<Id, CompetencyModelScore> competencyModelScoresById = new Map<Id, CompetencyModelScore>();
        
        for (Observed_Competency__c  observedCompetency : observedCompetencies) {
            if (observedCompetency.Observation__r.Type__c == 'Self') {
                this.SelfObservationPresent = true;
            }
            
            Id competencyModelId = observedCompetency.Competency__r.Competency_Model__c;
            
            if (!competencyModelScoresById.containsKey(competencyModelId)) {
                String competencyModelName;
                if (competencyModelTranslationsById.containsKey(competencyModelId)) {
                    competencyModelName = competencyModelTranslationsById.get(competencyModelId);
                }
                else {
                    competencyModelName = observedCompetency.Competency__r?.Competency_Model__r?.Name;
                }
                
                competencyModelScoresById.put(competencyModelId, new CompetencyModelScore(competencyModelName));
            }
            
            competencyModelScoresById.get(competencyModelId).add(observedCompetency,
                                                                 observedCompetency.Competency_Translation__r?.Name__c, observedCompetency.Skill_Translation__r?.Name__c);
        }
        
        BenchmarkScores = competencyModelScoresById.values();
    }
    
    /**
* Start of the calculation logic for averages and Highest/Lowest Scores and Gaps
* Calculate the average scores for all CompetencySkillAverageScore objects in BenchmarkScore. Competency and Skill included.
* Determine the 3 Highest and 3 Lowest Competency and Skill rankings and populate HighestScores and LowestScores
* Determine the 3 Highest and 3 Lowest Competency and Skill Gap rankings and populate TopPositiveGaps and TopNegativeGaps.
* Only positive and negative values are populated into the gap lists based on the name.
* This is by score, so if there are duplicates they will count as a single rank.
* This will also setup LowestScoringCompetencies for setupELearnings
*/
    private void calculateAveragesHighestLowestScoresAndGaps() {
        // Store Scores by Rank to determine the highest/lowest scores
        Map<Decimal, List<HighestLowestScore>> scoresByRank = new Map<Decimal, List<HighestLowestScore>>();
        Map<Decimal, List<HighestLowestGap>> scoresByGap = new Map<Decimal, List<HighestLowestGap>>();
        List<HighestLowestScore> competencyScores = new List<HighestLowestScore>();
        
        for (CompetencyModelScore benchmarkScore : BenchmarkScores) {
            for (CompetencySkillAverageScore competencySkilLAverageScore : benchmarkScore.CompetencySkillAverageScores) {
                calculateAverageHighestLowestScoreAndGap(competencySkilLAverageScore, null, scoresByRank, scoresByGap, competencyScores);
            }
            
            benchmarkScore.calculateOverallScores();
        }
        
        // Sort Scores from lowest to highest to more easily determine the highest/lowest
        List<Decimal> scores = new List<Decimal>(scoresByRank.keySet());
        scores.sort();
        
        for (integer i = 0; i < maxScoresPerRanking && i < scores.size(); i++) {
            setHighestLowestScore(scores[i], scoresByRank, LowestScores, i + 1);
        }
        
        // Loop in reverse to get the highest scores
        integer highScoresAdded = 0;
        for (integer i = scores.size() - 1; i >= 0 && highScoresAdded++ < 3; i--) {
            setHighestLowestScore(scores[i], scoresByRank, HighestScores, highScoresAdded);
        }
        
        // Sort Gaps from lowest to highest to more easily determine the highest/lowest
        List<Decimal> gaps = new List<Decimal>(scoresByGap.keySet());
        gaps.sort();
        
        for (integer i = 0; i < maxScoresPerRanking && i < gaps.size(); i++) {
            // If we reach any positive gaps they should not be considered an Area for Improvement 
            if (gaps[i] >= 0) {
                break;
            }
            
            setHighestLowestGap(gaps[i], scoresByGap, TopNegativeGaps, i + 1);
        }
        
        // Loop in reverse to get the highest gaps
        integer highGapsAdded = 0;
        for (integer i = gaps.size() - 1; i >= 0 && highGapsAdded++ < 3; i--) {
            // If we reach any negative gaps they should not be considered a Hidden Strength
            if (gaps[i] <= 0) {
                break;
            }
            
            setHighestLowestGap(gaps[i], scoresByGap, TopPositiveGaps, highGapsAdded);
        }
        
        // Sort the Competency Scores only to determine Lessons
        // Competencies are used to generate the Lessons since all Observed Competencies will have one
        competencyScores.sort();
        
        for (integer i = 0; i < 3 && i < competencyScores.size(); i++) {
            LowestScoringCompetencies.add(new CompetencyRecommendedELearnings(competencyScores[i]));
        }
    }
    
    /**
* Recursive method that will calculate the Average Score for a CompetencySkillAverageScore object,
* convert them to HighestLowestGap, which is also HighestLowestScore, and add them by rank and gap.
* If ManagerSkillScores is populated, each CompetencySkillAverageScore in that list will call this method
* @param competencySkilLAverageScore 
* @param competencyName 
* @param scoresByRank 
* @param scoresByGap
* @param competencyScores 
*/
    private void calculateAverageHighestLowestScoreAndGap(CompetencySkillAverageScore competencySkilLAverageScore,
                                                          String competencyName, Map<Decimal, List<HighestLowestScore>> scoresByRank, Map<Decimal, List<HighestLowestGap>> scoresByGap,
                                                          List<HighestLowestScore> competencyScores) {
                                                              competencySkilLAverageScore.calculateAverageScores();
                                                              
                                                              HighestLowestGap competencySkillScore = new HighestLowestGap(competencySkilLAverageScore, competencyName,
                                                                                                                           competencySkilLAverageScore.RecordId);
                                                              
                                                              // competencyScores will be null if this is called for a Skill
                                                              if (competencyScores != null) {
                                                                  competencyScores.add(competencySkillScore);
                                                              }
                                                              
                                                              if (!competencySkilLAverageScore.SkillScores.isEmpty()) {
                                                                  for (CompetencySkillAverageScore skillScore : competencySkilLAverageScore.SkillScores) {
                                                                      calculateAverageHighestLowestScoreAndGap(skillScore, competencySkilLAverageScore.Name, scoresByRank,
                                                                                                               scoresByGap, null);
                                                                  }
                                                                  return;
                                                              }
                                                              
                                                              Decimal score = competencySkilLAverageScore.ManagerAverageScore;
                                                              if (!scoresByRank.containsKey(score)) {
                                                                  scoresByRank.put(score, new List<HighestLowestScore>());
                                                              }
                                                              
                                                              scoresByRank.get(score).add(competencySkillScore);
                                                              
                                                              // Gaps only need to be calculated if Self-Observation is present
                                                              if (this.SelfObservationPresent) {
                                                                  Decimal gap = competencySkilLAverageScore.ManagerToSelfGap;
                                                                  if (!scoresByGap.containsKey(gap)) {
                                                                      scoresByGap.put(gap, new List<HighestLowestGap>());
                                                                  }
                                                                  
                                                                  scoresByGap.get(gap).add(competencySkillScore);
                                                              }
                                                          }
    
    /**
* Set rank on the HighestLowestScore object to indicate its rank as the Highest or Lowest Score
* @param score 
* @param scoresByRank 
* @param highestLowestScores 
* @param rank 
*/
    private void setHighestLowestScore(Decimal score, Map<Decimal, List<HighestLowestScore>> scoresByRank,
                                       List<HighestLowestScore> highestLowestScores, integer rank) {
                                           for (HighestLowestScore highLowScore : scoresByRank.get(score)) {
                                               // Clone the score on the off chance it is both a highest score and lowest score
                                               HighestLowestScore rankedScore = new HighestLowestScore(highLowScore, rank);
                                               highestLowestScores.add(rankedScore);
                                           }
                                       }
    
    /**
* Set rank on the HighestLowestGap object to indicate its rank as the Highest or Lowest Gap
* @param score 
* @param scoresByRank 
* @param highestLowestScores 
* @param rank 
*/
    private void setHighestLowestGap(Decimal gap, Map<Decimal, List<HighestLowestGap>> scoresByGap,
                                     List<HighestLowestGap> highestLowestGaps, integer rank) {
                                         for (HighestLowestGap highLowGap : scoresByGap.get(gap)) {
                                             // Clone the gap on the off chance it is both a highest gap and lowest gap
                                             HighestLowestGap rankedGap = new HighestLowestGap(highLowGap, rank);
                                             highestLowestGaps.add(rankedGap);
                                         }
                                     }
    
    /**
* Processes LowestScoringCompetencies to populate Lessons and only set Rank if there are Lessons
*/
    private void setupELearnings() {
        Set<Id> competencyIds = new Set<Id>();
        for (CompetencyRecommendedELearnings lowScoringCompetency : LowestScoringCompetencies) {
            competencyIds.add(lowScoringCompetency.RecordId);
        }
        
        Set<Id> benchmarkIds = new Set<Id>();
        benchmarkIds.add(BenchmarkId);
        Map<Id, List<Lesson__c>> lessonsByCompetencyId = new Map<Id, List<Lesson__c>>();
        for (Lesson__c lesson : LessonsSelector.selectByObservedCompetencyCompetencyAndBenchmark(competencyIds,benchmarkIds)) {
            Id competencyId = lesson.Observed_Competency__r.Competency__c;
            if (!lessonsByCompetencyId.containsKey(competencyId)) {
                lessonsByCompetencyId.put(competencyId, new List<Lesson__c>());
            }
            
            lessonsByCompetencyId.get(competencyId).add(lesson);
        }
        
        Integer rank = 1;
        for (CompetencyRecommendedELearnings lowScoringCompetency : LowestScoringCompetencies) {
            Id competencyId = lowScoringCompetency.RecordId;
            
            if (lessonsByCompetencyId.containsKey(competencyId)) {
                lowScoringCompetency.addLearnings(lessonsByCompetencyId.get(competencyId));
                lowScoringCompetency.Rank = rank++;
            }
        }
    }
    
    /**
* Inner class for storing Scores by Competency Model
*/
    public class CompetencyModelScore {
        public String Name {get; private set;}
        public transient Map<Id, CompetencySkillAverageScore> CompetencySkillAverageScoresById {get; private set;}
        public Decimal ManagerOverallScore {get; private set;}
        public Decimal SelfOverallScore {get; private set;}
        
        
        public List<CompetencySkillAverageScore> CompetencySkillAverageScores {
            get {
                return CompetencySkillAverageScoresById?.values();
            }
        }
        
        /**
* Calculate managerOverallScore by averaging all CompetencySkillAverageScores's ManagerAverageScore
* Calculate selfOverallScor by averaging all CompetencySkillAverageScores's SelfAverageScore
*/
        public void calculateOverallScores(){
            Decimal managerOverallScore = 0;
            Decimal selfOverallScore = 0;
            for (CompetencySkillAverageScore competencySkillAverageScore : CompetencySkillAverageScoresById.values()) {
                managerOverallScore += competencySkillAverageScore.ManagerAverageScore;
                selfOverallScore += competencySkillAverageScore.SelfAverageScore;
            } 
            
            managerOverallScore = managerOverallScore / CompetencySkillAverageScoresById.size();
            selfOverallScore = selfOverallScore / CompetencySkillAverageScoresById.size();
            
            this.ManagerOverallScore = managerOverallScore.setScale(2, RoundingMode.HALF_UP);
            this.SelfOverallScore = selfOverallScore.setScale(2, RoundingMode.HALF_UP);
        }
        
        /**
* Constructor with input of name
* @param name 
*/
        public CompetencyModelScore(String name) {
            this.Name = name;
            this.CompetencySkillAverageScoresById = new Map<Id, CompetencySkillAverageScore>();
            this.ManagerOverallScore = 0;
            this.SelfOverallScore = 0;
        }
        
        /**
* Convert the Observed Competency to a CompetencySkillAverageScore and add it to CompetencySkillAverageScoresById
* @param observedCompetency 
* @param competencyName 
* @param skillName 
*/
        public void add(Observed_Competency__c observedCompetency, String competencyName, String skillName) {
            if (!this.CompetencySkillAverageScoresById.containsKey(observedCompetency.Competency__c)) {
                this.CompetencySkillAverageScoresById.put(observedCompetency.Competency__c,
                                                          new CompetencySkillAverageScore(observedCompetency.Competency__r.Name, 
                                                                                          observedCompetency.Competency__c, competencyName));
            }
            
            this.CompetencySkillAverageScoresById.get(observedCompetency.Competency__c).add(observedCompetency, skillName);
        }
    }
    
    /**
* Class for storing the Average Score of Competencies or Skills
*/
    public class CompetencySkillAverageScore {
        public String Name {get; set;}
        public Id RecordId {get; set;}
        
        public transient Map<Id, CompetencySkillAverageScore> SkillScoresMap {get; set;}
        
        // Manager properties
        public transient List<Decimal> ManagerDirectScores {get; set;}
        public Decimal ManagerAverageScore {get; private set;}
        public Decimal PreviousManagerAverageScore {get; private set;}
        
        // Self properties
        public transient List<Decimal> SelfDirectScores {get; set;}
        public Decimal SelfAverageScore {get; private set;}
        public Decimal PreviousSelfAverageScore {get; private set;}    
        
        public Decimal ManagerToSelfGap {
            get {
                return  ManagerAverageScore - SelfAverageScore;
            }
        }
        
        public List<CompetencySkillAverageScore> SkillScores {
            get {
                return SkillScoresMap?.values();
            }
        }
        
        /**
* Calculate Manager and Self Average Scores
*/
        public void calculateAverageScores() {
            this.ManagerAverageScore = calculateAverageScores(this.ManagerDirectScores, this.SkillScoresMap, 'Coach');
            this.SelfAverageScore = calculateAverageScores(this.SelfDirectScores, this.SkillScoresMap, 'Self');   
        }
        
        /**
* Calculates Average Score by averaging the DirectScores or CompetencySkillAverageScore in
* SkillScoresMap. The collection that is not empty is used to average
*/
        private Decimal calculateAverageScores(List<Decimal> directScores, Map<Id, CompetencySkillAverageScore> skillScoresMap, String type) {
            Decimal averageScore = 0;
            
            
            if (!directScores.isEmpty()) {
                for (Decimal score : directScores) {
                    averageScore += score;
                }
                
                averageScore = averageScore / directScores.size();
            }
            else if (!skillScoresMap.isEmpty()) {
                for (CompetencySkillAverageScore skillScore : skillScoresMap.values()) {
                    skillScore.calculateAverageScores();
                    if (type == 'Coach') {
                        averageScore += skillScore.ManagerAverageScore;
                    }
                    else if (type == 'Self') {
                        averageScore += skillScore.SelfAverageScore;
                    }
                }
                
                averageScore = averageScore / skillScoresMap.size();
            }
            
            return averageScore.setScale(2, RoundingMode.HALF_UP);
        }
        
        /**
* Constructor to setup CompetencySkillAverageScore. Name is set to translatedName if passed in
* @param name 
* @param recordId 
* @param translatedName 
*/
        public CompetencySkillAverageScore(String name, Id recordId, String translatedName) {
            this.Name = String.isNotBlank(translatedName)
                ? translatedName
                : name;
            
            this.RecordId = recordId;
            this.ManagerDirectScores = new List<Decimal>();
            this.SkillScoresMap = new Map<Id, CompetencySkillAverageScore>();
            this.SelfDirectScores = new List<Decimal>();
            
        }
        
        /**
* If a Skill is present, converts the Skill Observed Competency to a CompetencySkillAverageScore and adds it
* to ManagerSkillScoresMap.
* Otherwise, adds the Score on the Observed Competency to ManagerDirectScores
* @param observedCompetency 
* @param skillName 
*/
        public void add(Observed_Competency__c observedCompetency, string skillName) {
            String type = observedCompetency.Observation__r.Type__c;
            Id skillId = observedCompetency.Skill__c;
            
            Decimal score = observedCompetency.Score__c != null
                ? Decimal.valueOf(observedCompetency.Score__c)
                : 0;
            
            List<Decimal> directScores;
            Map<Id, CompetencySkillAverageScore> skillScoresMap = this.SkillScoresMap;
            
            if (type == 'Coach') {
                directScores = ManagerDirectScores;
            }
            else if (type == 'Self') {
                directScores = SelfDirectScores;
            }
            
            if (skillId == null) {
                directScores.add(score);
            }
            else {
                if (!skillScoresMap.containsKey(skillId)) {
                    skillScoresMap.put(skillId, new CompetencySkillAverageScore(observedCompetency.Skill__r.Name__c,
                                                                                observedCompetency.Skill__c, skillName));
                }
                
                skillScoresMap.get(skillId).add(type, score);
            }
        }
        
        /**
* Add a direct Score to ManagerDirectScores or SelfDirectScores based on Type
* @param type 
* @param score 
*/
        public void add(String type, Decimal score) {
            if (type == 'Coach') {
                ManagerDirectScores.add(score);
            }
            else if (type == 'Self') {
                SelfDirectScores.add(score);
            }  
            
        }
    }
    
    /**
* Class for storing the Highest/Lowest Scores. This includes two name fields, for the Competency and Skill
*/
    public virtual class HighestLowestScore implements Comparable {
        public Integer Rank {get; set;}
        public String Competency {get; set;}
        public String Skill {get; set;}
        public Decimal Score {get; set;}
        public transient Id RecordId {get; set;}
        
        /**
* Constructor, Competency will be set to competencyName if it's passed in or
* competencySkillAverageScore.Name otherwise
* @param competencySkilLAverageScore 
* @param competencyName 
* @param recordId 
*/
        public HighestLowestScore(CompetencySkillAverageScore competencySkillAverageScore, String competencyName, Id recordId) {
            this.Competency = competencyName;
            this.Skill = competencySkillAverageScore.Name;
            this.Score = competencySkillAverageScore.ManagerAverageScore;
            this.RecordId = recordId;
            
            if (string.isBlank(this.Competency)) {
                this.Competency = this.Skill;
            }
        }
        
        /**
* Constructor to clone a HighestLowestScore to avoid duplicating Rank
* @param baseScore
* @param rank 
*/
        public HighestLowestScore(HighestLowestScore baseScore, Integer rank) {
            this.Competency = baseScore.Competency;
            this.Skill = baseScore.Skill;
            this.Score = baseScore.Score;
            this.RecordId = baseScore.RecordId;
            this.Rank = rank;
        }
        
        /**
* Compares HighestLowestScore by Score
* @param compareTo
* @return  `Integer`
*/
        public Integer compareTo(Object compareTo) {
            HighestLowestScore otherScore = (HighestLowestScore)compareTo;
            
            if (this.Score > otherScore.Score) {
                return 1;
            }
            else if (this.Score < otherScore.Score) {
                return -1;
            }
            
            return 0;
        }
    }
    
    /**
* Class for storing the 3 lowest Competency records and the recommended Lessons
*/
    public class CompetencyRecommendedELearnings {
        public String Name {get; private set;}
        public Integer Rank {get; set;}
        public transient Id RecordId {get; private set;}
        public List<RecommendedELearning> RecommendedELearnings {get; private set;}
        
        public Boolean HasELearnings {
            get {
                return !RecommendedELearnings.isEmpty();
            }
        }
        
        /**
* Constructor
* @param competencyScore 
*/
        public CompetencyRecommendedELearnings(HighestLowestScore competencyScore) {
            this.Name = competencyScore.Competency;
            this.RecordId = competencyScore.RecordId;
            this.RecommendedELearnings = new List<RecommendedELearning>();
        }
        
        /**
* Converts a Lesson to RecommendedELearning and adds it to RecommendedELearnings
* @param lessons 
*/
        public void addLearnings(List<Lesson__c> lessons) {
            for (Lesson__c lesson : lessons) {
                this.RecommendedELearnings.add(new RecommendedELearning(lesson));
            }
        }
    }
    
    /**
* Class for storing a Lesson
*/
    public class RecommendedELearning {
        public String Title {get; set;}
        public String Description {get; set;}
        public String Link {get; set;}
        
        /**
* Constructor sets up the RecommendedElearning using a Leson
* @param lesson 
*/
        public RecommendedELearning(Lesson__c lesson) {
            this.Title = lesson.Lesson_Template__r.Name;
            this.Description = lesson.Lesson_Template__r.Description__c;
            this.Link = lesson.URL__c;
        }
    }
    
    /**
* Class for storing a Observation Comments
*/
    public class ObservationComments {
        public Date Created_Date {get; set;}
        public String Comments {get; set;}
        
        /**
* Constructor sets up the ObservationComments using a Observation
* @param observation 
*/
        public ObservationComments(Observation__c observation) {
            this.Created_Date = observation.CreatedDate.date();
            this.Comments = observation.Comments__c;
        }
    }
    
    public class HighestLowestGap extends HighestLowestScore {
        public Decimal SelfScore {get; set;}
        public Decimal Gap {get; set;}
        
        /**
* Constructor, Competency will be set to competencyName if it's passed in or
* competencySkillAverageScore.Name otherwise
* @param competencySkilLAverageScore 
* @param competencyName 
* @param recordId 
*/
        public HighestLowestGap(CompetencySkillAverageScore competencySkillAverageScore, String competencyName, Id recordId) {
            super(competencySkillAverageScore, competencyName, recordId);
            
            this.SelfScore = competencySkillAverageScore.SelfAverageScore;
            this.Gap = competencySkillAverageScore.ManagerToSelfGap;
        }
        
        /**
* Constructor to clone a HighestLowestGap to avoid duplicating Rank
* @param baseGap
* @param rank 
*/
        public HighestLowestGap(HighestLowestGap baseGap, Integer rank) {
            super(baseGap, rank);
            
            this.SelfScore = baseGap.SelfScore;
            this.Gap = baseGap.Gap;
        }
    }
    
    private without sharing class WithoutSharing {
        public void insertRecords(List<SObject> records) {
            insert records;
        } 
    }
}