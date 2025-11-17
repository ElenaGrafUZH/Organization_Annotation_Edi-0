# UE-SBL.30004 Organisation and Annotation of Eukaryote Genomes

## Annotation of genes with the MAKER Pipeline 

### 5. Run Maker

#### Predicted Gene Models
```r
$ grep -c -w "gene" hifiasm_Edi-0.all.maker.gff
```
MAKER predicted 601'709 gene models in the genome of Edi-0.

#### Comparison to reference *A. Thaliana* genome
- arabidopsis thaliana: 27’448 gene count (https://www.uniprot.org/proteomes/UP000006548 (17.11.2025))
- MAKER predicted 601'709 preliminary gene models in the *Edi-0* assembly. This number is considerably higher than the genes annotated in the *Arabidopsis thaliana* reference genome, indicating that the current dataset likely includes redundant or fragmented predictions. Subsequent filtering can help refine this set to high-confidence gene models.

### 6. Filtering and Refining Gene Annotations





