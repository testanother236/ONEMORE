public with sharing class SDO_B2BCommerce_OrderDraftService {

    /*
     * =========================================================================
     * REQUEST / RESPONSE WRAPPERS
     * =========================================================================
     */

    public class CheckoutRequest {

        @InvocableVariable(required=true)
        public Id cartId;

        @InvocableVariable(required=false)
        public Id checkoutSessionId;

        @InvocableVariable(required=false)
        public Id pricebookId;
    }

    public class CheckoutResult {

        @InvocableVariable
        public Id orderId;

        @InvocableVariable
        public String status;

        @InvocableVariable
        public String message;
    }

    /*
     * =========================================================================
     * MAIN ENTRY POINT
     * =========================================================================
     */

    @InvocableMethod(
        label='Create Draft Order From Cart'
        description='Creates draft Order, Order Items, Taxes, Promotions and Delivery Groups from WebCart'
        category='B2B Commerce'
    )
    public static List<CheckoutResult> createDraftOrders(List<CheckoutRequest> requests) {

        List<CheckoutResult> results = new List<CheckoutResult>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        for (CheckoutRequest request : requests) {

            CheckoutResult result = new CheckoutResult();

            try {

                CartContext ctx = buildContext(request);

                createOrder(ctx);

                createDeliveryGroups(ctx);

                createOrderItems(ctx);

                createAdjustments(ctx);

                createTaxes(ctx);

                distributeCartPromotions(ctx);

                finalizeCheckoutSession(ctx);

                result.orderId = ctx.orderRecord.Id;
                result.status = 'SUCCESS';
                result.message = 'Draft order successfully created';

            } catch (Exception ex) {

                result.status = 'ERROR';
                result.message = ex.getMessage();

                System.debug(LoggingLevel.ERROR,
                    'Draft Order Creation Failed: ' + ex.getMessage()
                );
            }

            results.add(result);
        }

        return results;
    }

    /*
     * =========================================================================
     * CONTEXT OBJECT
     * =========================================================================
     */

    private class CartContext {

        public CheckoutRequest request;

        public WebCart cart;

        public List<CartItem> cartItems = new List<CartItem>();

        public List<CartTax> cartTaxes = new List<CartTax>();

        public List<WebCartAdjustmentGroup> promoGroups =
            new List<WebCartAdjustmentGroup>();

        public CartDeliveryGroup cartDeliveryGroup;

        public Order orderRecord;

        public OrderDeliveryGroup orderDeliveryGroup;

        public Map<Id, PricebookEntry> productToPbe =
            new Map<Id, PricebookEntry>();

        public Map<Id, OrderItem> productToOrderItem =
            new Map<Id, OrderItem>();
    }

    /*
     * =========================================================================
     * BUILD CONTEXT
     * =========================================================================
     */

    private static CartContext buildContext(CheckoutRequest request) {

        CartContext ctx = new CartContext();

        ctx.request = request;

        ctx.cart = [
            SELECT
                Id,
                AccountId,
                OwnerId,
                WebStoreId,
                PoNumber,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                BillingLatitude,
                BillingLongitude
            FROM WebCart
            WHERE Id = :request.cartId
            LIMIT 1
        ];

        List<CartDeliveryGroup> deliveryGroups = [
            SELECT
                Id,
                DesiredDeliveryDate,
                DeliverToName,
                ShippingInstructions,
                DeliverToStreet,
                DeliverToCity,
                DeliverToState,
                DeliverToPostalCode,
                DeliverToCountry,
                DeliverToLatitude,
                DeliverToLongitude,
                DeliveryMethodId
            FROM CartDeliveryGroup
            WHERE CartId = :request.cartId
            LIMIT 1
        ];

        if (!deliveryGroups.isEmpty()) {
            ctx.cartDeliveryGroup = deliveryGroups[0];
        }

        ctx.cartItems = [
            SELECT
                Id,
                Name,
                Product2Id,
                Type,
                Quantity,
                ListPrice,
                SalesPrice,
                TotalLineAmount,
                TotalAmount,
                TotalLineTaxAmount,
                AdjustmentAmount
            FROM CartItem
            WHERE CartId = :request.cartId
        ];

        ctx.cartTaxes = [
            SELECT
                Id,
                Name,
                Amount,
                CartItemId,
                TaxCalculationDate,
                TaxRate,
                TaxType
            FROM CartTax
            WHERE CartId = :request.cartId
        ];

        ctx.promoGroups = [
            SELECT
                Id,
                AdjustmentSource,
                TotalAmount,
                TotalAmountWithTax
            FROM WebCartAdjustmentGroup
            WHERE CartId = :request.cartId
        ];

        if (request.pricebookId != null) {

            for (
                PricebookEntry pbe : [
                    SELECT Id, Product2Id
                    FROM PricebookEntry
                    WHERE Pricebook2Id = :request.pricebookId
                ]
            ) {
                ctx.productToPbe.put(pbe.Product2Id, pbe);
            }
        }

        return ctx;
    }

    /*
     * =========================================================================
     * ORDER CREATION
     * =========================================================================
     */

    private static void createOrder(CartContext ctx) {

        WebCart cart = ctx.cart;

        Order ord = new Order();

        ord.AccountId = cart.AccountId;
        ord.OwnerId = cart.OwnerId;
        ord.SalesStoreId = cart.WebStoreId;

        ord.PoNumber = cart.PoNumber;

        ord.BillingStreet = cart.BillingStreet;
        ord.BillingCity = cart.BillingCity;
        ord.BillingState = cart.BillingState;
        ord.BillingPostalCode = cart.BillingPostalCode;
        ord.BillingCountry = cart.BillingCountry;

        ord.BillingLatitude = cart.BillingLatitude;
        ord.BillingLongitude = cart.BillingLongitude;

        ord.EffectiveDate = Date.today();
        ord.OrderedDate = System.now();

        ord.Status = 'Draft';

        if (ctx.request.pricebookId != null) {
            ord.Pricebook2Id = ctx.request.pricebookId;
        }

        insert ord;

        ctx.orderRecord = ord;
    }

    /*
     * =========================================================================
     * DELIVERY GROUP
     * =========================================================================
     */

    private static void createDeliveryGroups(CartContext ctx) {

        if (ctx.cartDeliveryGroup == null) {
            return;
        }

        CartDeliveryGroup source = ctx.cartDeliveryGroup;

        OrderDeliveryGroup target = new OrderDeliveryGroup();

        target.OrderId = ctx.orderRecord.Id;

        target.DeliverToName = source.DeliverToName;
        target.DeliveryInstructions = source.ShippingInstructions;

        target.DeliverToStreet = source.DeliverToStreet;
        target.DeliverToCity = source.DeliverToCity;
        target.DeliverToState = source.DeliverToState;
        target.DeliverToPostalCode = source.DeliverToPostalCode;
        target.DeliverToCountry = source.DeliverToCountry;

        target.DeliverToLatitude = source.DeliverToLatitude;
        target.DeliverToLongitude = source.DeliverToLongitude;

        target.OrderDeliveryMethodId = source.DeliveryMethodId;

        if (source.DesiredDeliveryDate != null) {
            target.DesiredDeliveryDate =
                Date.newInstance(
                    source.DesiredDeliveryDate.year(),
                    source.DesiredDeliveryDate.month(),
                    source.DesiredDeliveryDate.day()
                );
        }

        insert target;

        ctx.orderDeliveryGroup = target;
    }

    /*
     * =========================================================================
     * ORDER ITEMS
     * =========================================================================
     */

    private static void createOrderItems(CartContext ctx) {

        List<OrderItem> orderItems = new List<OrderItem>();

        for (CartItem cartItem : ctx.cartItems) {

            OrderItem oi = new OrderItem();

            oi.OrderId = ctx.orderRecord.Id;

            oi.OrderDeliveryGroupId =
                ctx.orderDeliveryGroup != null
                ? ctx.orderDeliveryGroup.Id
                : null;

            oi.Product2Id = cartItem.Product2Id;

            oi.Description = cartItem.Name;

            oi.Type = mapOrderItemType(cartItem.Type);

            oi.Quantity = cartItem.Quantity;

            oi.UnitPrice =
                cartItem.SalesPrice != null
                ? cartItem.SalesPrice
                : cartItem.ListPrice;

            oi.ListPrice =
                cartItem.ListPrice != null
                ? cartItem.ListPrice
                : oi.UnitPrice;

            oi.TotalLineAmount = cartItem.TotalLineAmount;

            oi.ServiceDate = ctx.orderRecord.EffectiveDate;

            if (
                ctx.productToPbe.containsKey(cartItem.Product2Id)
            ) {
                oi.PricebookEntryId =
                    ctx.productToPbe.get(cartItem.Product2Id).Id;
            }

            orderItems.add(oi);
        }

        if (orderItems.isEmpty()) {
            return;
        }

        insert orderItems;

        for (Integer i = 0; i < orderItems.size(); i++) {

            CartItem source = ctx.cartItems[i];

            ctx.productToOrderItem.put(
                source.Product2Id,
                orderItems[i]
            );
        }
    }

    /*
     * =========================================================================
     * ADJUSTMENTS
     * =========================================================================
     */

    private static void createAdjustments(CartContext ctx) {

        List<OrderItemAdjustmentLineItem> adjustments =
            new List<OrderItemAdjustmentLineItem>();

        for (CartItem cartItem : ctx.cartItems) {

            Decimal adjustment = calculateAdjustment(cartItem);

            if (adjustment == null || adjustment == 0) {
                continue;
            }

            OrderItem relatedOi =
                ctx.productToOrderItem.get(cartItem.Product2Id);

            if (relatedOi == null) {
                continue;
            }

            OrderItemAdjustmentLineItem adj =
                new OrderItemAdjustmentLineItem();

            adj.OrderItemId = relatedOi.Id;
            adj.Amount = adjustment;
            adj.Name = 'Cart Adjustment';

            adjustments.add(adj);
        }

        if (!adjustments.isEmpty()) {
            insert adjustments;
        }
    }

    /*
     * =========================================================================
     * TAXES
     * =========================================================================
     */

    private static void createTaxes(CartContext ctx) {

        if (ctx.cartTaxes.isEmpty()) {
            return;
        }

        Map<Id, CartItem> cartItemMap = new Map<Id, CartItem>();

        for (CartItem ci : ctx.cartItems) {
            cartItemMap.put(ci.Id, ci);
        }

        List<OrderItemTaxLineItem> taxes =
            new List<OrderItemTaxLineItem>();

        for (CartTax tax : ctx.cartTaxes) {

            CartItem sourceItem = cartItemMap.get(tax.CartItemId);

            if (sourceItem == null) {
                continue;
            }

            OrderItem relatedOi =
                ctx.productToOrderItem.get(sourceItem.Product2Id);

            if (relatedOi == null) {
                continue;
            }

            OrderItemTaxLineItem line =
                new OrderItemTaxLineItem();

            line.OrderItemId = relatedOi.Id;

            line.Name = tax.Name;

            line.Amount = tax.Amount;

            line.Rate = tax.TaxRate;

            line.Type = 'Actual';

            line.TaxEffectiveDate = tax.TaxCalculationDate;

            taxes.add(line);
        }

        if (!taxes.isEmpty()) {
            insert taxes;
        }
    }

    /*
     * =========================================================================
     * PROMOTIONS
     * =========================================================================
     */

    private static void distributeCartPromotions(CartContext ctx) {

        if (
            ctx.promoGroups.isEmpty() ||
            ctx.productToOrderItem.isEmpty()
        ) {
            return;
        }

        List<OrderItemAdjustmentLineItem> promoAdjustments =
            new List<OrderItemAdjustmentLineItem>();

        Integer productCount = ctx.productToOrderItem.size();

        if (productCount == 0) {
            return;
        }

        for (WebCartAdjustmentGroup promo : ctx.promoGroups) {

            Decimal splitAmount =
                promo.TotalAmount / productCount;

            for (OrderItem oi : ctx.productToOrderItem.values()) {

                OrderItemAdjustmentLineItem adjustment =
                    new OrderItemAdjustmentLineItem();

                adjustment.OrderItemId = oi.Id;

                adjustment.Amount = splitAmount;

                adjustment.Name = promo.AdjustmentSource;

                promoAdjustments.add(adjustment);
            }
        }

        if (!promoAdjustments.isEmpty()) {
            insert promoAdjustments;
        }
    }

    /*
     * =========================================================================
     * CHECKOUT SESSION
     * =========================================================================
     */

    private static void finalizeCheckoutSession(CartContext ctx) {

        if (ctx.request.checkoutSessionId == null) {
            return;
        }

        try {

            CartCheckoutSession session = [
                SELECT Id, OrderId, NextState
                FROM CartCheckoutSession
                WHERE Id = :ctx.request.checkoutSessionId
                LIMIT 1
            ];

            session.OrderId = ctx.orderRecord.Id;
            session.NextState = 'Complete';

            update session;

        } catch (Exception ex) {

            System.debug(
                LoggingLevel.WARN,
                'Unable to update checkout session: ' + ex.getMessage()
            );
        }
    }

    /*
     * =========================================================================
     * HELPERS
     * =========================================================================
     */

    private static Decimal calculateAdjustment(CartItem item) {

        Decimal adjustment =
            item.AdjustmentAmount == null
            ? 0
            : item.AdjustmentAmount;

        if (
            item.TotalAmount != null &&
            item.TotalLineAmount != null &&
            item.TotalLineTaxAmount != null &&
            item.TotalAmount != item.TotalLineAmount
        ) {

            adjustment +=
                (
                    item.TotalAmount
                    - item.TotalLineTaxAmount
                    - item.TotalLineAmount
                );
        }

        return adjustment;
    }

    private static String mapOrderItemType(String cartType) {

        switch on cartType {

            when 'Product' {
                return 'Order Product';
            }

            when 'Charge' {
                return 'Delivery Charge';
            }

            when else {
                return 'Order Product';
            }
        }
    }
}