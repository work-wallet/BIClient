namespace WorkWallet.BI.ClientServices.Processor
{
    // work around non-generic fields returned from the API (fix this in future release)

    public class SiteAuditsContext : Context
    {
        public int SiteAuditCount
        {
            get
            {
                return Count;
            }
            set
            {
                Count = value;
            } 
        }

        public int FullSiteAuditCount
        {
            get
            {
                return FullCount;
            }
            set
            {
                FullCount = value;
            }
        }
    }
}
