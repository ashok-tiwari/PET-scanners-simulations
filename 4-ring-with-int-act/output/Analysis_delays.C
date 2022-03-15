using namespace std;
void Analysis_delays()
{
	gROOT->Reset();
	char filename[100]= "scat_800_MBq.root";
	TFile *f = new TFile(filename, "READ");

	// create output .dat files
	FILE *delays;
	delays = fopen("output/Delay_800_MBq.dat", "w");
	if(delays == NULL)
	{
		printf("Cannot open file!");
	}

	// delays coincidence data
	TTree *htree = (TTree *) f->Get("delay");
	Int_t Hitentries = (Int_t) htree->GetEntries();

	// Pull relevant variables
	float sinogramTheta;
	float sinogramS;

	TBranch *b_sinogramTheta = htree->GetBranch("sinogramTheta");
	b_sinogramTheta->SetAddress(&sinogramTheta);
	TBranch *b_sinogramS = htree->GetBranch("sinogramS");
	b_sinogramS->SetAddress(&sinogramS);

	// loop over each entry
	for (int i = 0; i < Hitentries; i++)
	{
		b_sinogramS->GetEntry(i);
		b_sinogramTheta->GetEntry(i);
	// print total coincidences onto coincidence.dat file into two columns
		fprintf(delays,"%f %f\n",sinogramTheta,sinogramS);
	}
	//close output files
	fflush(delays);
	fclose(delays);
}

