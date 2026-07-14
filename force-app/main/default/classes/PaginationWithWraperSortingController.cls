public with sharing class PaginationWithWraperSortingController
{
    //public String ByTitle;
    //public String ByPage;
    public enum SORT_BY { ByTitle,ByPage,ByAuther,ByPrice,ByPublishingDate }
    
    //Variable to decide the member on which sorting should be performed
    public static SORT_BY sortBy = SORT_BY.ByTitle;
    
    public Book[] books {get; set;}
    
    public String columnStr{get; set;}
    
    public PaginationWithWraperSortingController()
    {
        books = new Book[]{
            new Book('Salesforce Handbook','Jeff Douglas',360,35,Date.newInstance(2011, 03, 20)),
            new Book('Let Us C','Yashavant P. Kanetkar',593,58,Date.newInstance(2008, 03, 21)),
            new Book('Head First Design Patterns ','Elisabeth Freeman',678,28,Date.newInstance(2004, 11,01))
        };
    }
    
    public void changeOrderBy()
    {
        if(columnStr != null && columnStr != '')
        {
            if(columnStr == 'ByTitle')
                sortBy = SORT_BY.ByTitle;
            else if(columnStr == 'ByPage')
                sortBy = SORT_BY.ByPage;
            else if(columnStr == 'ByAuther')
                sortBy = SORT_BY.ByAuther;
            else if(columnStr == 'ByPrice')
                sortBy = SORT_BY.ByPrice;
            else if(columnStr == 'ByPublishingDate')
                sortBy = SORT_BY.ByPublishingDate;
            books.sort();
        }
    }
    
    public class Book implements Comparable
    {
        public String BookTitle {get; set;}
        public String Author {get; set;}
        public Integer TotalPages {get; set;}
        public Double Price {get; set;}
        public Date publishingDate {get; set;}
    
        public Book(String bt, String a, Integer tp, Double p, Date pd)
        {
            BookTitle = bt;
            Author = a;
            TotalPages = tp;
            Price = p;
            publishingDate = pd;
        }
    
        public Integer compareTo(Object objToCompare) {
            //Sort by BookName Alphabetically
            if(sortBy == SORT_BY.ByTitle)
            {
                return BookTitle.compareTo(((Book)objToCompare).BookTitle);
            }
            else if(sortBy == SORT_BY.ByPrice) //Sort by Book price
            {
                return Integer.valueOf(Price - ((Book)objToCompare).Price);
            }
            else if(sortBy == SORT_BY.ByAuther)
            {
                return Author.compareTo(((Book)objToCompare).Author);
            }
            else if(sortBy == SORT_BY.ByPage)
            {
                return Integer.valueOf(TotalPages - ((Book)objToCompare).TotalPages);
            }
            else if(sortBy == SORT_BY.ByPublishingDate)
            {
                Date fromDatee = objToCompare != null ? ((Book)objToCompare).publishingDate : System.today();           
                return fromDatee.daysBetween(this.publishingDate);
            }
            return 0;
        }
    }
}